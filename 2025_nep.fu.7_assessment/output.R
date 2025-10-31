#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("output")
outdir<- "output/"
datadir<- "data/"
modeldir<- "model/"

#Clear files from outdir directories
unlink(list.files(outdir, full.names = T, recursive = T))

file.copy(paste0(datadir,"nephup.fl.",catch.year,".rdata"), outdir, overwrite=T)
file.copy(paste0(datadir, c("international.landings.csv","fladen_TV_results_bias_corrected.csv","Mean weights in landings.csv")), outdir, overwrite=T)
file.copy(paste0(modeldir, c("fladen_Exploitation summary.csv")), outdir, overwrite=T)
plots.advice(wk.dir = outdir,
             f.u="fladen", MSY.hr = HR["Fmsy"],stock.object=nephup.fl,
             international.landings = "international.landings.csv",
             tv_results = "fladen_TV_results_bias_corrected.csv",
             Exploitation_summary = "fladen_Exploitation summary.csv")