### Plot Bison MSMC vs PSMC output - Alex Jackson
### 4/6/16

# this library is useful for plotting
library(ggplot2)

# set working directory - all files referenced will be relative to here
setwd("~/Dropbox/MAGenomics_2015/PSMC_Scholarship/errorAnalysis/PSMC_vs_MSMC/plots")

# Function to read MSMC input files + scale time and population size
# Generation time = 8 y, mutation rate = 1.25e-8 mutations/nucleotide/generation (for bison)
GEN = 8
MU = 1.25e-8
# from tutorial at http://nicercode.github.io/guides/repeating-things/ - and Paul!
scaleMSMCInput=function(MSMCInputFile){
  MSMCInputTable<-read.table(MSMCInputFile, header=TRUE)
  MSMCInputTable[,"scaledTime"]<-GEN*MSMCInputTable$left_time_boundary/MU # adds an extra column scaledTime onto the data frame
  MSMCInputTable[,"scaledPopSize"]<-1/(2*MU*MSMCInputTable$lambda_00)
  return(MSMCInputTable)
}

# # Read and scale MSMC input files for plotting
EurBisMSMC <- scaleMSMCInput("MSMC/EuropeanBison.Cow_UMD3_1.realigned_AllAutosomes_MSMCOutput.final.txt")

### Plot with steps using ggplot - Ben (NOT NEEDED HERE)
# First recal that I changed your function at the start to not have the "points()" line, so it just created a list of
# twenty dataframes of bootstrapped data for each Bison type. lapply is a function that says "take the list of things" and
# perform some function on them. You said "take the list of file names" and "scaleMSMCInput them".
#TassieDevilDat <- lapply(TassieDevil_BS_files, scaleMSMCInput)
#Wooddat <- lapply(Wood_BS_files, scaleMSMCInput)
#Eurodat <- lapply(European_BS_files, scaleMSMCInput)

# I began by combining the MSMC data into one data.frame by "row-binding" them using rbind(). 
# whoops, deleted this part

EurBisMSMC # view it if you want...

# STUFF FROM BEN ABOUT GGPLOT
# I begin by making a ggplot() object called g1. I didn't define the data I'd use in the ggplot() part as it makes things harder later on. I prefer to do
# this when I'm layering plot on plot...there's an number of things going on here. I'll try and explain them in list, but you could find these on Hadley's
# documentation if you wanted.
# theme_bw(): makes the background black and white.
# in geom_step, size: the thickness of the plotted line.
# scale_y_log10(): Makes the y axis in the log 10 scale. This would through an error if any values were 0 (as log(0) in undefined).
# xlab(), ylab(): I use this to change the axis labels
# coord_cartesion: The range I will plot over on the x and y axes, defined by xlim and ylim as 2D vectors of the form c(min,max).
# theme(legend.title=element_blank()): Removes the ugly legen title.
# g1 <- ggplot() + theme_bw() + scale_y_log10() + geom_step(aes(x=alldat$scaledTimeLo,y=alldat$scaledPopSize),size=1, colour="purple", linetype="dotted") + ylab("Scaled Population Size\n") +
#   xlab(expression(paste("Scaled Time (mu = 1.25e-8)\n"))) + coord_cartesian(xlim=c(80,max(alldat$scaledTimeLo)),ylim=c(min(alldat$scaledPopSize)*0.9,1.1*max(alldat$scaledPopSize))) +
#   theme(legend.title=element_blank()) + scale_x_log10() +
#   geom_step(aes(alldat$scaledTimeHi, y=alldat$scaledPopSize), size=1, colour="blue", linetype="dotted")
# g1
# l is just the number of bootstrap samples I add (defined by the number of data.frames in the list A1dat defined earlier) 
#l <- length(TassieDevilDat)

# SKIP THIS IF YOU DON'T CARE ABOUT PSMC
# we want to compare them with the PSMC plots
EurBisPSMC = read.delim("PSMC/EuropeanBison29Autosomes_Int40*1_Iter20.psmcData")
EurBisPSMC_theta0 = 0.009314 # from the file PSMC/EuropeanBison29Autosomes_Int40*1_Iter20.psmc. From "FinalReport.pdf", "PSMC find θ for you, which can be obtained by going to the final iteration of the PSMC run (go to the .psmc file) and taking the second value of the row with the TR."
s = 100 # number of bp per bin

EurBisPSMC_N0 = EurBisPSMC_theta0 / (4*MU) / s # find N_0 from theta and mu
EurBisPSMC$t_unscaled = EurBisPSMC$t_k*2 * EurBisPSMC_N0 * GEN # converts to real time (sorry confusing nomenclature... "unscaled" here is real time, while for MSMC "scaled" is real time...)
EurBisPSMC$pop_hist = EurBisPSMC$lambda_k * EurBisPSMC_N0 # converts from units of N_0 to effective population size
# 

########### BEN'S ADDITIONS


# Create my new MSMC df
EurBisMSMCNew <- data.frame(Time=EurBisMSMC$time_index, Scaled.Time=EurBisMSMC$scaledTime, Ne=EurBisMSMC$scaledPopSize, Method=rep("MSMC (40*1)", length(EurBisMSMC$scaledPopSize)) ) # now we just take the things we're interested in from the old data frame

EurBisPSMCNew <- data.frame(Time=EurBisPSMC$t_k, Scaled.Time=EurBisPSMC$t_unscaled, Ne=EurBisPSMC$pop_hist, Method=rep("PSMC (40*1)", length(EurBisPSMC$pop_hist)) )

comb_dat <- rbind(EurBisMSMCNew,EurBisPSMCNew) # "row-bind", effectively making the MSMC table sit on top of the PSMC table. 


comb_datWith0 <- comb_dat
comb_datWith0$Scaled.Time[1] = 1 # set the t = 0 to t = 1. This allows us to still have the first time point.

comb_dat <- comb_dat[comb_dat$Scaled.Time != 0,] # here, we're removing any time value which is equal to zero. This is necessary if you'd like to plot time on a log scale (which is often easier to look at)


cols <- c("MSMC (40*1)" = "red","PSMC (40*1)" = "blue") # we will use this later, so the different lines have different colours

g_MSMC_PSMC = ggplot(comb_dat,aes(x=Scaled.Time,y=Ne,colour=Method)) + theme_bw() + scale_y_log10() + geom_step(size=1) + ylab("Scaled Population Size\n") +
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(min(comb_dat$Scaled.Time)*0.9, max(comb_dat$Scaled.Time)*1.1), ylim=c(min(comb_dat$Ne)*0.9,max(comb_dat$Ne)*1.1)) +
  theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10() + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC for the European Bison")
# plot by typing "g_MSMC_PSMC", or export as a pdf (below)
# ggsave(filename='EuropeanBison29AutosomesPSMCMSMCComparison.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC)