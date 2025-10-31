#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("model")
modeldir<- "model/"
datadir<- "data/"

#Clear files from modeldir directories
unlink(list.files(modeldir, full.names = T, recursive = T))

#Latest advice given (in tonnes)
latest.advice<- c(9149,9149) #9149 tonnes catch advice given in 2024 for 2025.

#FORECAST
########################################################################################
##Forecast for next year using the lastest survey point
survey<- paste(datadir, "fladen", "_TV_results.csv", sep="")
international<- paste0(datadir, "international.landings.csv")

# Creates an exploitation table for the years in the survey file which can be 1 year more than in the
# landings and stock object (for an autumn advice)
#exploitation.table.2014(wk.dir = paste(Wkdir, "fishstats", sep=""), f.u = "fladen", stock.object=nephup.fl, international.landings = international, survey=survey)
exploitation.table(wk.dir = modeldir, f.u = "fladen", stock.object=nephup.fl, international.landings = international, survey=survey)

#Check definition for F2013 (average vs last year)

data.yr<- catch.year
av.yrs<- (catch.year-2):catch.year  
# disc.av.yrs<- 2000:year #long term average (given 2017 high discard rate)
# land.av.yrs<- disc.av.yrs #long term average (given 2017 high discard rate)
exp.tab.fl<- read.csv(paste0(modeldir, "fladen_Exploitation summary.csv"))
#btrigger<- min(exp.tab.fl[exp.tab.fl$year<2010, "adjusted.abundance"], na.rm=T)

# 2015 abundance is lower than Btrigger. Adjust HR:
#Fmsy<- 7.5
#Fmsy_adjusted<- round(Fmsy*exp.tab.fl[exp.tab.fl$year==2015, "adjusted.abundance"]/btrigger, 1)

HR<- list(
  #  Fmsy_adjusted=Fmsy_adjusted,
  Flower=6.6,
  Fmsy = 7.5,
  F35SpR = 11.2,
  Fmax = 16.4,
  Fyear = exp.tab.fl[exp.tab.fl$year==(data.yr),"harvest.ratio"],   
  Fav.yrs = round(mean(exp.tab.fl[exp.tab.fl$year %in% av.yrs,"harvest.ratio"]), 1)
)
HR<- sapply(HR, as.vector)
#Flow<- 6.6
#extra.options<- unique(c(seq(floor(min(HR)), ceiling(max(HR)), by=1), seq(Flow, HR[names(HR)=="Fmsy"], by=0.1))); extra.options<- extra.options[!extra.options %in% HR] 
#HR<- c(HR, extra.options)
HR<- c(sort(HR[names(HR) %in% c("Fmsy_adjusted", "Fmsy")]),sort(HR[!names(HR) %in% c("Fmsy_adjusted", "Fmsy")]))
names(HR)[which(names(HR) %in% "Fyear")]<- paste0("F",(data.yr))    
names(HR)[which(names(HR) %in% "Fav.yrs")]<- paste0("F",av.yrs[1],"_",av.yrs[3])

#Forecast table as required by WGNSSK 2017
file.copy(paste0(datadir, c("Mean_weights.csv")), modeldir, overwrite=T)
forecast.table.WGNSSK(wk.dir = modeldir,
                      fu="FU7",hist.sum.table = "fladen_Exploitation summary.csv",
                      mean.wts="Mean_weights.csv",
                      land.wt.yrs=av.yrs, disc.wt.yrs=av.yrs, disc.rt.yrs=av.yrs, 
                      h.rates=HR, d.surv =25, latest.advice=latest.advice)


