### Plot Bison MSMC vs PSMC output - Alex Jackson
### 22/5/16

#require(plyr)
library(ggplot2)

# set working directory
#setwd("~/Documents/Semester_Years/2015/Semester2/MSMC/")

### FILE ACQUIRED FROM: alex@Mint17-HP-Studio-XPS-1645 ~/Dropbox/MAGenomics_2015/PSMC Scholarship/MSMC_AlexJulien/50LargestContigs $ scp acad-colab1@acad2.rc.adelaide.edu.au:/localscratch/AussieGenomes/TasmanianDevil/bwa_n0.04_seed/MSMC_50LongestContigs/TasmanianDevilSanger.Devil7_0.realigned_7Contigs5Mb_MSMC2Output.final.txt .

setwd("~/Dropbox/MAGenomics_2015/PSMC_Scholarship/errorAnalysis/PSMC_vs_MSMC/plots")

# Function to read MSMC input files + scale time and population size + print them into existing plot (for bootstrap)
# Generation time = 20 y, mutation rate = 1.25e-8 mutations/nucleotide/generation

GEN = 8
MU = 1.25e-8
#MU=2.5e-8
# from tutorial at http://nicercode.github.io/guides/repeating-things/ - and Paul!
scaleMSMCInput=function(MSMCInputFile){
  MSMCInputTable<-read.table(MSMCInputFile, header=TRUE)
  MSMCInputTable[,"scaledTime"]<-GEN*MSMCInputTable$left_time_boundary/MU
#  MSMCInputTable[,"scaledTimeHi"]<-GEN_hi*MSMCInputTable$left_time_boundary/MU
  MSMCInputTable[,"scaledPopSize"]<-1/(2*MU*MSMCInputTable$lambda_00)
  return(MSMCInputTable)
}

# # Read and scale MSMC input files for plotting
# TassieDevil.7Contigs5Mb.output<-read.table("TasmanianDevilSanger.Devil7_0.realigned_7Contigs5Mb_MSMCOutput.final.txt", header=TRUE)
# TassieDevil.7Contigs5Mb.output[,"scaledTime"]<-(GEN*TassieDevil.7Contigs5Mb.output$left_time_boundary/MU)
# TassieDevil.7Contigs5Mb.output[,"scaledPopSize"]<-(1/(2*MU*TassieDevil.7Contigs5Mb.output$lambda_00))

EurBisMSMC <- scaleMSMCInput("MSMC/EuropeanBison.Cow_UMD3_1.realigned_AllAutosomes_MSMCOutput.final.txt")
#TassieDevil.7Contigs5Mb.output <- scaleMSMCInput("TasmanianDevilSanger.Devil7_0.realigned_50LongestContigs_MSMCOutput.final.txt")

# Read all boostrap input files
#TassieDevil_BS_files <- lapply(1:7, function(x){paste0("TasmanianDevilSanger.Devil7_0.realigned_7Contigs5Mb_MSMCOutput_BS", x, ".final.txt")}) 


### Plot with steps usign ggplot - Ben 
# First recal that I changed your function at the start to not have the "points()" line, so it just created a list of
# twenty dataframes of bootstrapped data for each Bison type. lapply is a function that says "take the list of things" and
# perform some function on them. You said "take the list of file names" and "scaleMSMCInput them".
#TassieDevilDat <- lapply(TassieDevil_BS_files, scaleMSMCInput)
#Wooddat <- lapply(Wood_BS_files, scaleMSMCInput)
#Eurodat <- lapply(European_BS_files, scaleMSMCInput)

# I began by combining the MSMC data into one data.frame by "rwo-binding" them using rbind(). 
#alldat <- TassieDevil50Contigs
# allow log scaling
#EurBisMSMC = EurBisMSMC[EurBisMSMC$scaledTime != 0,]
#alldat = alldat[alldat$scaledTimeHi != 0,]

EurBisMSMC # view it...
# Then I just labelled them all by type. Recal that dim() returns a vector of the form (a,b) where a is the number of rowds, and b is the number of columns.
# Hence if I use dim(df)[1], I'm just asking for the first entry, which would be the number of rows for an arbitrary data.frame called "df".
#alldat$Type <- c(rep('Ancient Steppe A16121 - 6.13X',dim(TassieDevil.7Contigs5Mb.output)[1]),rep('Modern Wood Bison - 6.31X',dim(WoodBison.CowGenome.realigned_MSMC.output)[1]),
#                 rep('Modern European Bison - 6.32X',dim(EuropeanBison.CowGenome.realigned_MSMC.output)[1]))

# This value varies how "see through" the bootstrap lines will be. 1 is a solid line, closer to zero gives very see through.
#alph <- 0.15

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

# # Here I loop through the bootstraps, and so for the ith bootstrapped data ..
# for(i in 1:l){
#   # I make a temporary data.frame just like we did for the initial data set
#   tmpDat <- TassieDevilDat[[i]]
#   # Label it by Bison type
#   #tmpDat$Type <- alldat$Type
#   # Add the step plot.
#   g1 <- g1 + geom_step(data=tmpDat,aes(x=scaledTimeLo,y=scaledPopSize),alpha=alph)
# } 
# # here's what it looks like....
# g1
#ggsave(filename='MSMC.pdf',height=20,width=40,units='cm')

# we want to compare them with the PSMC plots
EurBisPSMC = read.delim("PSMC/EuropeanBison29Autosomes_Int40*1_Iter20.psmcData")
EurBisPSMC_theta0 = 0.009314 # from the file PSMC/EuropeanBison29Autosomes_Int40*1_Iter20.psmc. From "FinalReport.pdf", "PSMC find θ for you, which can be obtained by going to the final iteration of the PSMC run (go to the .psmc file) and taking the second value of the row with the TR."
s = 100 # no bp per bin

EurBisPSMC_N0 = EurBisPSMC_theta0 / (4*MU) / s
EurBisPSMC$t_unscaled = EurBisPSMC$t_k*2 * EurBisPSMC_N0 * GEN
EurBisPSMC$pop_hist = EurBisPSMC$lambda_k * EurBisPSMC_N0
# 
# g2 <- g1 + geom_step(data=td_dat, aes(x=t_unscaled_low, y=pop_hist), size=1, colour="purple") + geom_step(data=td_dat, aes(x=t_unscaled_hi, y=pop_hist), size=1, colour="blue") +scale_x_log10() + coord_cartesian(xlim=c(80, max(td_dat$t_unscaled_hi)), ylim = c(min(td_dat$pop_hist), 150000)) + ggtitle("Population dynamics of Tasmanian Devil, as recovered by PSMC and MSMC") +
#   scale_colour_manual(name="Legend", values = c("MSMC Lo" = "purple", "MSMC Hi" = "blue", "PSMC Lo" = "purple", "PSMC Hi" = "blue")) +
#   scale_linetype_manual(name="Legend", values = c("MSMC Lo" = "dotted", "MSMC Hi" = "bdotted", "PSMC Lo" = "solid", "PSMC Hi" = "solid"))
# g2
# ggsave(filename='PSMC_MSMC_Comparison_160302.pdf',height=20,width=40,units='cm',plot=g2)


# kan_tas_plot = ggplot(kan_tas, aes(x=Times, y=Pops, colour = Type ))+theme_bw()+geom_step(size=1) +
#   xlab("\nYears Before Present")+ylab(bquote(''*N[e]*'\n'))+ ggtitle('Red Kangaroo and Tasmanian Devil Effective Population Estimates from PSMC') + coord_cartesian(xlim=c(20,4*10^5),ylim=c(0,10000))+
#   geom_ribbon(aes(x=lgTime,ymax=lgmupper,ymin=lgmlower),colour='yellow',alpha=0.2,fill='yellow') +
#   geom_vline(xintercept=Humans, colour='black') + geom_vline(aes(xintercept=cutoffs, colour=Type), linetype="dashed")


########### BEN'S ADDITIONS


# Create my new MSMC df
EurBisMSMCNew <- data.frame(Time=EurBisMSMC$time_index, Scaled.Time=EurBisMSMC$scaledTime, Ne=EurBisMSMC$scaledPopSize, Method=rep("MSMC", length(EurBisMSMC$scaledPopSize)) )

# # Now plot a little more simply
# ggplot(alldatBen,aes(x=Scaled.Time,y=Ne,colour=Estimate)) + theme_bw() + scale_y_log10() + geom_step(linetype="dashed",size=1) + ylab("Scaled Population Size\n") + xlab(expression(paste("Scaled Time (mu = 1.25e-8)\n"))) + coord_cartesian(xlim=c(80,max(alldat$scaledTimeLo)),ylim=c(min(alldat$scaledPopSize)*0.9,1.1*max(alldat$scaledPopSize))) +
#   theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10()

EurBisPSMCNew <- data.frame(Time=EurBisPSMC$t_k, Scaled.Time=EurBisPSMC$t_unscaled, Ne=EurBisPSMC$pop_hist, Method=rep("PSMC", length(EurBisPSMC$pop_hist)) )

comb_dat <- rbind(EurBisMSMCNew,EurBisPSMCNew)

comb_datWith0 <- comb_dat
comb_datWith0$Scaled.Time[1] = 1 # so I can log this
comb_dat <- comb_dat[comb_dat$Scaled.Time != 0,]


cols <- c("MSMC" = "red","PSMC" = "blue")

# hmm for some reason, PSMC and MSMC are mixed up?
 #plot(td_dat$t_unscaled_hi,td_dat$pop_hist,type="s",log="xy") # this is the psmc results. ALL GOOD NOW THO

g_MSMC_PSMC = ggplot(comb_dat,aes(x=Scaled.Time,y=Ne,colour=Method)) + theme_bw() + scale_y_log10() + geom_step(size=1) + ylab("Scaled Population Size\n") +
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(min(comb_dat$Scaled.Time)*0.9, max(comb_dat$Scaled.Time)*1.1), ylim=c(min(comb_dat$Ne)*0.9,max(comb_dat$Ne)*1.1)) +
  theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10() + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC for the European Bison")
ggsave(filename='EuropeanBison29AutosomesPSMCMSMCComparison.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC)

g_MSMC_PSMC_With0 = ggplot(comb_datWith0,aes(x=Scaled.Time,y=Ne,colour=Method)) + theme_bw() + scale_y_log10() + geom_step(size=1) + ylab("Scaled Population Size\n") +
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(min(comb_datWith0$Scaled.Time)*0.9, max(comb_datWith0$Scaled.Time)*1.1), ylim=c(min(comb_datWith0$Ne)*0.9,max(comb_datWith0$Ne)*1.1)) +
  theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10() + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC for the European Bison")
ggsave(filename='EuropeanBison29AutosomesPSMCMSMCComparisonWith0.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC_With0)

############

# Nigel wanted a plot of the time intervals so that he could see how they were distributed. Do this both for PSMC and MSMC, in logged and unlogged time.

# Logged, with 0
g_MSMC_PSMC_TimeIntervalsLogWith0 = ggplot(comb_datWith0,aes(x=Scaled.Time,y=c(rep(0,length(comb_datWith0[comb_datWith0$Method == "MSMC",]$Method)), rep(1, length(comb_datWith0[comb_datWith0$Method == "PSMC",]$Method)) ),colour=Method)) + theme_bw() + geom_point(size=1) + 
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(min(comb_datWith0$Scaled.Time)*0.9, max(comb_datWith0$Scaled.Time)*1.1)) + scale_x_log10() + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC time intervals (log time)")
ggsave(filename='EuropeanBison29AutosomesPSMCMSMCLogTimeWith0.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC_TimeIntervalsLogWith0)
# Logged, without 0
g_MSMC_PSMC_TimeIntervalsLogWithout0 = ggplot(comb_datWith0,aes(x=Scaled.Time,y=c(rep(0,length(comb_datWith0[comb_datWith0$Method == "MSMC",]$Method)), rep(1, length(comb_datWith0[comb_datWith0$Method == "PSMC",]$Method)) ),colour=Method)) + theme_bw() + geom_point(size=1) + 
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(500, max(comb_datWith0$Scaled.Time)*1.1)) + scale_x_log10() + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC time intervals (log time, without the first MSMC point)")
ggsave(filename='EuropeanBison29AutosomesPSMCMSMCLogTimeWithout0.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC_TimeIntervalsLogWithout0)
# Unlogged, without 0
g_MSMC_PSMC_TimeIntervalsUnlogged = ggplot(comb_datWith0,aes(x=Scaled.Time,y=c(rep(0,length(comb_datWith0[comb_datWith0$Method == "MSMC",]$Method)), rep(1, length(comb_datWith0[comb_datWith0$Method == "PSMC",]$Method)) ),colour=Method)) + theme_bw() + geom_point(size=1) + 
  xlab(expression(paste("Scaled Time (mu = 1.25e-8), gen = 8 yr\n"))) + coord_cartesian(xlim=c(500, max(comb_datWith0$Scaled.Time)*1.1)) + scale_color_manual(values=cols) + ggtitle("PSMC vs MSMC time intervals (unlogged time)")
ggsave(filename='EuropeanBison29AutosomesPSMCMSMCUnloggedTime.pdf',height=21,width=29.7,units='cm',plot=g_MSMC_PSMC_TimeIntervalsUnlogged)

