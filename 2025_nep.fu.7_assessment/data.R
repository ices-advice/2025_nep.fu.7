library(icesTAF)

taf.bootstrap()
taf.library(NephAssess)
source("libraries.R")

#set working data year
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("data")
datadir<- "data/" #

#Clear files from datadir directories
unlink(list.files(datadir, full.names = T, recursive = T))

#copy input files from initialdatadir to datadir
file.copy(list.files("bootstrap/data/", full.names = TRUE), datadir, overwrite=T)

#Previous year stock object
stock.object="nephup.fl.2023.rdata"

#Previous year international landings
old.international=paste0(datadir,"international.landings_2023.csv")


# COMERCIAL DATA
##############################################################################################
# Commercial data work up
# Create stock object
nephup.fl<- nephup(wdir=datadir, stock.object=stock.object, lfile="Frsfl.txt", filenames="File_listFL.txt")
#  Effort - new Katy Barratt effort data 
nephort.fl <- list(days=nephort(wdir = datadir, eff.file = "eff_FL_days.txt"), kwdays=nephort(wdir = datadir, eff.file = "eff_FL_kwdays.txt"))
save(nephort.fl,nephup.fl,file=paste0(datadir,"nephup.fl.", catch.year, ".rdata"))

# landings, effort, mean size summary tables
# The landings.csv table that this function produces needs to be updated by hand as
#  it only includes '4 gears' in the 'Trawl' category which makes the Scottish subtotal too low  
tables(datadir,nephup.fl, nephort.fl$days, f.u="fladen")

# This function creates a total landings file including all countries (uses StockOverview.txt from Intercatch for non Scottish Countries and Landings.csv for Scottish landings)
create.international.landings(wdir=datadir, fu="nep.fu.7", new.data.year=catch.year, 
                              old.int.landings=old.international, 
                              new.scotland.landings=paste0(datadir,"Landings.csv"), 
                              IC_file=paste0(datadir,"StockOverview.txt"))

#  mean weights in landings table - can do more than 1 FU at a time
invisible(mean.weight(datadir,stock.list=list(nephup.fl)))
invisible(mean.wt.disc(datadir, stock.list=list(nephup.fl)))
mean.weight.catches(wk.dir=datadir, stock=nephup.fl, MCS=25)
