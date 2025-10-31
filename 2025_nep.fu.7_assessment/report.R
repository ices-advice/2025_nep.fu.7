#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("report")
reportdir<- "report/"
outdir<- "output/"

#Clear files from outdir directories
unlink(list.files(reportdir, full.names = T, recursive = T))

#load stock object
load(paste0(outdir,"nephup.fl.",catch.year,".rdata"))

##############################################################################################

#Calculate mean sizes and create time series plot
mean.length <-mean.sizes(nephup.fl)
plot.mean.sizes(reportdir,nephup.fl,mean.length)

#Mean wt in landings plot
fl.means<- read.csv(paste0(outdir, "Mean weights in landings.csv"))
#ff.means<- read.csv(paste0(substr(Wkdir,1,nchar(Wkdir)-3),"FF/Mean weights in landings.csv"))
#mf.means<- read.csv(paste0(substr(Wkdir,1,nchar(Wkdir)-3),"MF/Mean weights in landings.csv"))
#dh.means<- read.csv("C:/nephrops/Carlos/Assessment/WGNSSK 14/DH/Nephup/Mean weights in landings.csv") #mean wts from DH in 2015 based on just 2 trips, thus ignored here
#plot.mean.weights(wk.dir=Wkdir, st1=fl.means, st2=ff.means, st3=mf.means, st4=dh.means, fu.legend=c("Fladen", "Firth of Forth", "Moray Firth", "Devil's Hole"))


##following script produces mean size trends male/female  as per Ewen
#  set up df for LF plot - the tables which are output are incorrect - uses 
# lower bound to calculate mean length
tmp <-FLCore::trim(nephup.fl,year=2000:catch.year)
disc <-as.data.frame(seasonSums(tmp@discards.n))
catch <-as.data.frame(seasonSums(tmp@catch.n))
land <-as.data.frame(seasonSums(tmp@landings.n))

#Year, Sex, Length, Landings, Discards, Catch
LF.data.frame <-data.frame(Year=disc$year,Sex=disc$unit,
                           Length=disc$lengths,Landings=land$data,Discards=disc$data,
                           Catch=catch$data)
png(paste0(reportdir, "LFD_Fl.png"),width = 800, height = 1000)
plot.ld(LF.data.frame,"FU 7",range(tmp,'minyear'),range(tmp,'maxyear'),25,35)
dev.off()

# Could use this instead 
catch.ldist.plot(flneph.object = nephup.fl, years=c(2000,catch.year), extra.space=3)
length.freq.dist(neph.object = nephup.fl, av.years = c(catch.year))

#WGNSSK old LF plot for advice sheets
#prepare data frame format
CatchLDsYr<- LF.data.frame
CatchLDsYr$Discards<- NULL #remove discard column as not needed
names(CatchLDsYr)<- c("Year","Sex","Length","LandNaL","CatchNaL") # rename fields
CatchLDsYr$Sex<- substr(CatchLDsYr$Sex,1,1)# Take the first letter (either M or F) from Sex ("Male" and "Female") for NEP_LD_plot_ICES function
#Run new function. Output goes to reportdir
NEP_LD_plot_ICES(df=subset(CatchLDsYr,CatchNaL>0), FU="7", FUMCRS=25, RefLth=35, out.dir=reportdir)

#Plot landings and quartery landings
nephup.quarterly.plots(reportdir,tmp, nephort.fl$days)

#Sex ratio plot
sex.ratio.plot(wdir=reportdir, stock.obj=nephup.fl, print.output=F, type="year")
sex.ratio.plot(wdir=reportdir, stock.obj=tmp, print.output=F, type="quarter")

#Landings long term plot
nephup.long.term.plots_kw_effort_aggregated(outdir,stock=nephup.fl,effort.data.days=nephort.fl$days, effort.data.kwdays=nephort.fl$kwdays,
                                            international=T,international.landings="international.landings.csv", output.dir=reportdir)
