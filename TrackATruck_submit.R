rm(list=ls())
getwd()

pacman::p_load(data.table,ggplot2, magrittr, tidyr, parallel, foreach, doParallel, iterators,dplyr, stringr)

#options================================================================

core_num<-14
core_type<-'FORK'

#support data===========================================================
Btable<-data.table(Bin=as.character(paste('Bin',1:23, sep = '')) %>% factor(levels = as.character(paste('Bin',1:23, sep = ''))),
                   value=0)
er<-fread('er.csv')
er$Bin<-paste('Bin',er$Bin, sep = '') %>%
  factor(levels = as.character(paste('Bin',1:23, sep = '')))

binfreq<-fread('Binfreq.csv')[,!c('cartype','weight')]

#main================================================================

filelist<-list.files('data', pattern = 'data', full.names = TRUE, recursive = TRUE)


cl<-makeCluster(core_num, type = core_type)
registerDoParallel(cl)

raw<-foreach(i = filelist,
             .inorder = FALSE,
             .packages = c('data.table','dplyr','magrittr')) %dopar% {

               raw<-fread(i, colClasses = c('character',
                                            rep('numeric',2)))
               raw$Time<-sub(raw$Time, pattern = 'T', replacement = ' ') %>%
                 sub(pattern = 'Z', replacement = '')
               raw<-raw[Time != '']
               raw$Time<-as.POSIXct(raw$Time,'%Y-%m-%d %H:%M:%S')

               Vmean <- mean(raw$Speed[seq(from = 1, to = length(raw$Speed), by = 30)], na.rm = TRUE)
               Vsd <- sd(raw$Speed[seq(from = 1, to = length(raw$Speed), by = 30)], na.rm = TRUE)
               Vupper<-Vmean+2*Vsd
               Vlower<-Vmean-2*Vsd

               #step1
               step1<-data.table(V13 = Vmean,
                                 V14 = Vsd,
                                 vupper = Vupper,
                                 vlower = Vlower)

               step2<-binfreq[vmean < Vupper & vmean > Vlower]
               step2<-step2[,c('vupper','vlower'):=list(
                 vmean+2*vsd,vmean-2*vsd
               )]

               #step2_2


               step2_2<-step2[,FWeight:=ifelse(Vupper >= vupper & Vlower >= vlower,
                                               (vupper-Vlower)/(Vupper-Vlower),
                                               ifelse(Vupper >= vupper & Vlower <= vlower,
                                                      (vupper-vlower)/(Vupper-Vlower),
                                                      ifelse(Vupper <= vupper & Vlower <= vlower,
                                                             (Vupper-vlower)/(Vupper-Vlower),
                                                             ifelse(Vupper <= vupper & Vlower >= vlower,
                                                                    (Vupper-Vlower)/(vupper-vlower),1))))]

               step3<-step2_2

               for (j in paste('Bin',1:23, sep = '')) {
                 eval(parse(text = paste('step3$',j,'<-step3$',j,'*step3$FWeight', sep = '')))
               }


               #step3-2
               step3_2<-step1

               for (j in paste('Bin',1:23, sep = '')) {
                 eval(parse(text = paste('step3_2$',j,'<-mean(step3$',j,',na.rm = TRUE)', sep = '')))
               }

               total<-step3_2[1,5:27] %>% as.matrix() %>% sum()


               for (j in paste('Bin',1:23, sep = '')) {
                 eval(parse(text = paste('step3_2$',j,'<-step3_2$',j,'/total', sep = '')))
               }


               #step4
               step4<-step3_2 %>% melt(id = c('V13','V14','vupper','vlower'), variable.name = 'Bin')
               step4$Bin<-factor(step4$Bin, levels = paste('Bin', 1:23, sep = ''))
               step4$Bintype<-'Simulated'

               binobserve<-table(raw$Bin) %>% data.table() %>% setnames(c('Bin','cnt'))
               binobserve$value<-binobserve$cnt/sum(binobserve$cnt)
               binobserve$Bin<-paste('Bin', binobserve$Bin, sep = '') %>%
                 factor(levels = paste('Bin', 1:23, sep = ''))
               binobserve<-binobserve[!is.na(Bin)][,!c('cnt')]


               binobserve<-rbind(binobserve, Btable[!(Bin %in% binobserve$Bin)])
               binobserve$Bintype<-'Observed'

               result<-rbind(step4[,c('Bin','value','Bintype')], binobserve)[,Data:=i]
               return(result)
             } %>% rbindlist(fill = TRUE)

stopCluster(cl)
stopImplicitCluster()


summary<-merge(raw[Bintype == 'Observed'], er, by = 'Bin', all.x = TRUE)
summary2<-merge(raw[Bintype == 'Simulated'], er, by = 'Bin', all.x = TRUE)

for (i in c('NOx','PM2.5')) {
  eval(parse(text = paste('summary$',i,'<-summary$',i,'*summary$value', sep = '')))
  eval(parse(text = paste('summary2$',i,'<-summary2$',i,'*summary2$value', sep = '')))
}

summary<-rbind(summary,summary2)

summary<-summary[,.(NOx = sum(NOx, na.rm = TRUE),
                PM2.5 = sum(PM2.5, na.rm = TRUE)), by = c('Data','Bintype')] %>%
  melt(id = c('Data','Bintype'), variable.name = 'pt', value.name = 'weighted_er')


summary$em_opmode<-summary$weighted_er*400
summary$Bintype<-paste(summary$Bintype, '_opmode', sep = '')
summary<-summary[,!c('weighted_er')] %>% spread(Bintype,em_opmode)

# NOx plot
ggplot(summary[pt == 'NOx'],aes(x = Observed_opmode,y = Simulated_opmode))+
  geom_point()+
  geom_abline(slope = 1, linetype = 'dashed')+
  scale_x_continuous(limit = c(0,62))+
  scale_y_continuous(limit = c(0,62))+
  theme_bw()

# PM2.5 plot
ggplot(summary[pt == 'PM2.5'],aes(x = Observed_opmode,y = Simulated_opmode))+
  geom_point()+
  geom_abline(slope = 1, linetype = 'dashed')+
  scale_x_continuous(limit = c(0,1.04))+
  scale_y_continuous(limit = c(0,1.04))+
  theme_bw()

