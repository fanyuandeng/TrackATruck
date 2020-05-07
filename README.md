# About
TrackATruck is an emission inventory approach of heavy-duty trucks (HDTs). This repository includes the validations of the simulated opMode module in TrackATruck approach. More detail, see the article "A Big data Approach to Improving the Vehicle Emission Inventory in China". The supporting data of this article are also included in this repository. 

*NOTE: This repository is not a R packages. User should download and run the code in R environment. In addition, several R packages are needed, as shown in the **System requirements.***

## Authors
Fanyuan Deng, Zhaofeng Lv, Lijuan Qi, Xiaotong Wang, Mengshuang Shi and Huan Liu*.
## License
This repository is licensed under the Apache License 2.0, see the LICENSE file for details.

## File descriptions
1. TrackATruck_submit.R: codes of the validations of simulated opMode module in TrackATruck approach. Line 58-86 are equivalent with the equations 1 and 2 in the article.
2. data.rar: the test data, including 400 1-Hz trajectories of heavy-duty trucks (>= 25 ton) with MOVES Opmodes (Bin). The unit of Speed is meter per second.
3. er.csv: test emission rates data. It is used to map the MOVES Opmodes to the pollutant emission rates (NOx and PM2.5).
4. Binfreq: test HDT trajectories with MOVES Opmodes. It is used to calculated the simulated Opmodes for the test data (in data.rar).
5. source data file.xlsx: the supporting data for the article "A Big data Approach to Improving the Vehicle Emission Inventory in China".

# Running the demo step-by-step (TrackATruck_submit.R)
We recommend that user's device meets the following system requirements. User can run the codes by following steps.

## System requirements
1. Operating system: Windows 10/Linux.
2. R version: 3.5.1 or higher.
3. R packages versions: pacman(>=0.5.1), data.table(>=1.11.8), ggplot2(>=3.1.1), magrittr(>=1.5), tidyr(>=0.8.2), parallel(>=3.5.1), foreach(>=1.4.4), doParallel(>=1.0.14), dplyr(>=0.8.3), stringr(>=1.3.1).
4. Rstudio version: RStudio Desktop(>=1.2.1335) or Rstudio Server(>=1.1.463).

## Installation guide
Please access the websites https://cran.r-project.org/ and https://rstudio.com/ for installations of R/Rstudio.
The expected install time is about helf hour.

## Step 1: preparing the files and setting operations
1. Downloading all files in your workspace.
2. Decompressing the data.rar. The data includes 400 sample HDT driving trajectory. The duration is 400 seconds for each trajectory.
3. Opening the TrackATruck_submit.R, and revising the operations (Line 8-9) to fit the available CPU cores. For example, the following codes are work on a device with 4 CPU cores:

>core_num<-4  
>core_type<-'SOCK'

Where the  object core_num is the available CPU cores, and the core_type is the supported type of cluster, more detail see package [snow](https://cran.r-project.org/web/packages/snow/snow.pdf).  


## Step 2: running the codes
1. Running the line 10-129: the model output (summary) from files in data.rar will save in the global environment. The output data includes the observed/simulated emissions of the input sample trajectories.
2. Runing the line 132-137 or line 140-145: the xy plot will display on the plot panel in Rstudio.
3. The expected run time for this demo is from several minutes to helf hour.
