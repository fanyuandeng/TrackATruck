# About
TrackATruck is an emission inventory approach of heavy-duty trucks (HDTs). This repository includes the validations of the simulated opMode module in TrackATruck approach. More detail, see the article "". The supporting data of this article are also included in this repository. 

*NOTE: This repository is not a R packages. User should download and run the code in R environment. In addition, several R packages are needed, as shown in the following imports.*

*Imports: pacman, data.table, ggplot2, magrittr, tidyr, parallel, foreach, doParallel, iterators, dplyr, stringr.* 

# Authors
Fanyuan Deng, Zhaofeng Lv, Lijuan Qi, Xiaotong Wang, Mengshuang Shi and Huan Liu
# License
Apache License 2.0

# File descriptions
1. TrackATruck_submit.R: codes of the validations of simulated opMode module in TrackATruck approach. Line 58-86 are equivalent with the equations 1 and 2 in the article.
2. data.rar: the test data, including 400 1-Hz trajectories of heavy-duty trucks (>= 25 ton) with MOVES Opmodes (Bin). The unit of Speed is meter per second.
3. er.csv: test emission rates data. It is used to map the MOVES Opmodes to the pollutant emission rates (NOx and PM2.5).
4. Binfreq: test HDT trajectories with MOVES Opmodes. It is used to calculated the simulated Opmodes for the test data (in data.rar).
5. source data file.xlsx: the supporting data in the article "".
