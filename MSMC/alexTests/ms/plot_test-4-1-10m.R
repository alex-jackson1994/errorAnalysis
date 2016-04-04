### Plot Bison MSMC output - Jared Decker - Julien Soubrier - Ben Rohrlach
# 3 Dec 2014 - modified June 2015

#require(plyr)
library(ggplot2)

# set working directory
#setwd("~/Documents/Semester_Years/2015/Semester2/MSMC/")

### FILE ACQUIRED FROM: alex@Mint17-HP-Studio-XPS-1645 ~/Dropbox/MAGenomics_2015/PSMC Scholarship/MSMC_AlexJulien/50LargestContigs $ scp acad-colab1@acad2.rc.adelaide.edu.au:/localscratch/AussieGenomes/TasmanianDevil/bwa_n0.04_seed/MSMC_50LongestContigs/TasmanianDevilSanger.Devil7_0.realigned_7Contigs5Mb_MSMC2Output.final.txt .

setwd("~/Dropbox/MAGenomics_2015/PSMC_Scholarship/errorAnalysisAlexSem1/MSMC/alexTests/ms")

# Function to read MSMC input files + scale time and population size + print them into existing plot (for bootstrap)
# Generation time = 2y or 3.5y - mutation rate = 1.25e-8 s/s/g or 2.5e-8 s/s/g(human one)
#GEN=2
GEN_lo = 20
GEN_hi = 30
MU = 1.25e-8
#MU=2.5e-8
# from tutorial at http://nicercode.github.io/guides/repeating-things/ - and Paul!
scaleMSMCInput=function(MSMCInputFile){
  MSMCInputTable<-read.table(MSMCInputFile, header=TRUE)
  MSMCInputTable[,"scaledTimeLo"]<-GEN_lo*MSMCInputTable$left_time_boundary/MU
  MSMCInputTable[,"scaledTimeHi"]<-GEN_hi*MSMCInputTable$left_time_boundary/MU
  MSMCInputTable[,"scaledPopSize"]<-1/(2*MU*MSMCInputTable$lambda_00)
  return(MSMCInputTable)
}

# # Read and scale MSMC input files for plotting
# TassieDevil.7Contigs5Mb.output<-read.table("TasmanianDevilSanger.Devil7_0.realigned_7Contigs5Mb_MSMCOutput.final.txt", header=TRUE)
# TassieDevil.7Contigs5Mb.output[,"scaledTime"]<-(GEN*TassieDevil.7Contigs5Mb.output$left_time_boundary/MU)
# TassieDevil.7Contigs5Mb.output[,"scaledPopSize"]<-(1/(2*MU*TassieDevil.7Contigs5Mb.output$lambda_00))

alldat <- scaleMSMCInput("msmcOut_test-4-1-10m.msmc.final.txt")
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
alldat = alldat[alldat$scaledTimeLo != 0,]
alldat = alldat[alldat$scaledTimeHi != 0,]

alldat
# Then I just labelled them all by type. Recal that dim() returns a vector of the form (a,b) where a is the number of rowds, and b is the number of columns.
# Hence if I use dim(df)[1], I'm just asking for the first entry, which would be the number of rows for an arbitrary data.frame called "df".
#alldat$Type <- c(rep('Ancient Steppe A16121 - 6.13X',dim(TassieDevil.7Contigs5Mb.output)[1]),rep('Modern Wood Bison - 6.31X',dim(WoodBison.CowGenome.realigned_MSMC.output)[1]),
#                 rep('Modern European Bison - 6.32X',dim(EuropeanBison.CowGenome.realigned_MSMC.output)[1]))

# This value varies how "see through" the bootstrap lines will be. 1 is a solid line, closer to zero gives very see through.
alph <- 0.15

# I begin by making a ggplot() object called g1. I didn't define the data I'd use in the ggplot() part as it makes things harder later on. I prefer to do
# this when I'm layering plot on plot...there's an number of things going on here. I'll try and explain them in list, but you could find these on Hadley's
# documentation if you wanted.
# theme_bw(): makes the background black and white.
# in geom_step, size: the thickness of the plotted line.
# scale_y_log10(): Makes the y axis in the log 10 scale. This would through an error if any values were 0 (as log(0) in undefined).
# xlab(), ylab(): I use this to change the axis labels
# coord_cartesion: The range I will plot over on the x and y axes, defined by xlim and ylim as 2D vectors of the form c(min,max).
# theme(legend.title=element_blank()): Removes the ugly legen title.
g1 <- ggplot() + theme_bw() + scale_y_log10() + geom_step(aes(x=alldat$scaledTimeLo,y=alldat$scaledPopSize),size=1, colour="purple") + ylab("Scaled Population Size\n") +
  xlab(expression(paste("Scaled Time (mu = 1.25e-8)\n"))) + coord_cartesian(xlim=c(min(alldat$scaledTimeLo)*0.9,max(alldat$scaledTimeHi)),ylim=c(min(alldat$scaledPopSize)*0.9,1.1*max(alldat$scaledPopSize))) +
  theme(legend.title=element_blank()) + scale_x_log10() +
  geom_step(aes(alldat$scaledTimeHi, y=alldat$scaledPopSize), size=1, colour="blue")

### we want to add the truth as well
### alex@Mint17-HP-Studio-XPS-1645 ~/Dropbox/MAGenomics_2015/PSMC_Scholarship/errorAnalysisAlexSem1/MSMC/alexTests/ms $ msHOT-lite 4 1 -t 7156.0000000 -r 2000.0000 10000000 -eN 0 5 -eG 0.000582262 1318.18 -eG 0.00232905 -329.546 -eG 0.00931619 82.3865 -eG 0.0372648 -20.5966 -eG 0.149059 5.14916 -eN 0.596236 0.5 | /home/alex/Desktop/data/Internship/MSMC/msmc-tools-master/ms2multihetsep.py 1 10000000 > test-4-1-10m.txt

g1


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
ggsave(filename='MSMC.pdf',height=20,width=40,units='cm')

# we want to compare them with the PSMC plots
td_dat = read.delim("tasmanianDevil50LargestContigsInt40*1.txt")
td_theta0 = 0.003445 # from the file tasmanianDevilBp3053144200Int40*1.psmc
s = 100 # no bp per bin
td_gen_low = 2
td_gen_hi = 3.5
td_N0 = td_theta0 / (4*MU) / s
td_dat$t_unscaled_low = td_dat$t_k*2 * td_N0 * td_gen_low
td_dat$t_unscaled_hi = td_dat$t_k*2 * td_N0 * td_gen_hi
td_dat$pop_hist = td_dat$lambda_k * td_N0

g2 <- g1 + geom_step(data=td_dat, aes(x=t_unscaled_low, y=pop_hist), size=1, colour="purple") + geom_step(data=td_dat, aes(x=t_unscaled_hi, y=pop_hist), size=1, colour="blue") +scale_x_log10() + coord_cartesian(xlim=c(80, max(td_dat$t_unscaled_hi)), ylim = c(min(td_dat$pop_hist), 150000)) + ggtitle("Population dynamics of Tasmanian Devil, as recovered by PSMC and MSMC") +
  scale_colour_manual(name="Legend", values = c("MSMC Lo" = "purple", "MSMC Hi" = "blue", "PSMC Lo" = "purple", "PSMC Hi" = "blue")) +
  scale_linetype_manual(name="Legend", values = c("MSMC Lo" = "dotted", "MSMC Hi" = "bdotted", "PSMC Lo" = "solid", "PSMC Hi" = "solid"))
g2
ggsave(filename='PSMC_MSMC_Comparison_160302.pdf',height=20,width=40,units='cm',plot=g2)


# kan_tas_plot = ggplot(kan_tas, aes(x=Times, y=Pops, colour = Type ))+theme_bw()+geom_step(size=1) +
#   xlab("\nYears Before Present")+ylab(bquote(''*N[e]*'\n'))+ ggtitle('Red Kangaroo and Tasmanian Devil Effective Population Estimates from PSMC') + coord_cartesian(xlim=c(20,4*10^5),ylim=c(0,10000))+
#   geom_ribbon(aes(x=lgTime,ymax=lgmupper,ymin=lgmlower),colour='yellow',alpha=0.2,fill='yellow') +
#   geom_vline(xintercept=Humans, colour='black') + geom_vline(aes(xintercept=cutoffs, colour=Type), linetype="dashed")


########### BEN'S ADDITIONS


# Create my new df
alldatBen <- data.frame(Time=rep(alldat$time_index,2),Scaled.Time=c(alldat$scaledTimeLo,alldat$scaledTimeHi),Ne=rep(alldat$scaledPopSize,2),Estimate=rep(c("Lower Estimate","Upper Estimate"),each=dim(alldat)[1]),Method=rep("MSMC", length(alldat$scaledPopSize*2)) )

# Now plot a little more simply
ggplot(alldatBen,aes(x=Scaled.Time,y=Ne,colour=Estimate)) + theme_bw() + scale_y_log10() + geom_step(linetype="dashed",size=1) + ylab("Scaled Population Size\n") + xlab(expression(paste("Scaled Time (mu = 1.25e-8)\n"))) + coord_cartesian(xlim=c(80,max(alldat$scaledTimeLo)),ylim=c(min(alldat$scaledPopSize)*0.9,1.1*max(alldat$scaledPopSize))) +
  theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10()

tdBen <- data.frame(Time=rep(td_dat$k,2),Scaled.Time=c(td_dat$t_unscaled_low,td_dat$t_unscaled_hi),Ne=rep(td_dat$pop_hist,2),
Estimate=rep(c("Lower Estimate","Upper Estimate"),each=dim(td_dat)[1]),Method='PSMC')

comb_dat <- rbind(alldatBen,tdBen)
cols <- c("Lower Estimate" = "purple","Upper Estimate" = "blue")

# hmm for some reason, PSMC and MSMC are mixed up?
 #plot(td_dat$t_unscaled_hi,td_dat$pop_hist,type="s",log="xy") # this is the psmc results. ALL GOOD NOW THO

g3 = ggplot(comb_dat,aes(x=Scaled.Time,y=Ne,colour=Estimate,linetype=Method)) + theme_bw() + scale_y_log10() + geom_step(size=1) + ylab("Scaled Population Size\n") +
  xlab(expression(paste("Scaled Time (mu = 1.25e-8)\n"))) + coord_cartesian(xlim=c(80,max(tdBen$Scaled.Time)),ylim=c(min(tdBen$Ne)*0.9,1.1*max(alldat$scaledPopSize))) +
  theme(legend.title=element_blank(),axis.title.x=element_text(vjust=-1.3)) + scale_x_log10() + scale_color_manual(values=cols)
g3
ggsave(filename='PSMC_MSMC_Comparison_160306_50LargestContigs.pdf',height=20,width=40,units='cm',plot=g3)
