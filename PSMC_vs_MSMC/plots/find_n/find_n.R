# For the Eurpoean bison...
# find n, the number of MSMC time bins needed to have T1(MSMC) be roughly equal to that of the 40-bin PSMC's T1(PSMC)
# T1 is the first non-zero time point

# we know that
T1_PSMC = 470.6476 # (see first time point from EurBisPSMC from EuropeanBison29AutosomesPSMCvsMSMC.R)

# the formula for t1(MSMC, unscaled) is t1 = -ln(1-1/n)
# thus, T1(MSMC) = -ln(1-1/n) * (GEN yrs/generation) / (MU mutations/bp/generation) (by the conversion to real time specified by Schiffels)
GEN = 8
MU = 1.25e-8
Ti_MSMC = function(i,n) {
  return ( -log(1-i/n) * GEN / MU )
}

# now work out the difference in T1_PSMC and T1_MSMC for varying n
tvals = NULL
nvals = NULL
for (n in 1:100) {
  tvals = append(tvals, Ti_MSMC(1,n) )
  nvals = append(nvals, n)
}
df = data.frame(nvals, tvals)
df

#### okay, so this is producing different values than I'm getting in the MSMC bison output
# is there a scaling factor
scaleMSMCInput=function(MSMCInputFile){
  MSMCInputTable<-read.table(MSMCInputFile, header=TRUE)
  MSMCInputTable[,"scaledTime"]<-GEN*MSMCInputTable$left_time_boundary/MU
  #  MSMCInputTable[,"scaledTimeHi"]<-GEN_hi*MSMCInputTable$left_time_boundary/MU
  MSMCInputTable[,"scaledPopSize"]<-1/(2*MU*MSMCInputTable$lambda_00)
  return(MSMCInputTable)
}
setwd("~/Dropbox/MAGenomics_2015/PSMC_Scholarship/errorAnalysis/PSMC_vs_MSMC/plots/find_n/")

EurBisMSMC <- scaleMSMCInput("../MSMC/EuropeanBison.Cow_UMD3_1.realigned_AllAutosomes_MSMCOutput.final.txt")

t = EurBisMSMC$scaledTime[2:length(EurBisMSMC$scaledTime)]

tratios = NULL
for (i in 1:length(t))  # -1 bc we don't want to include 0
{
  tratios[i] = Ti_MSMC(i,40) / t[i]
}
tratios
scaleFactor = mean(tratios) # ???? it's 1790.292, WHY?????
# so the theoretical is 1790x larger than the ACTUAL OUTPUT????

# therefore we need to update our function to account for that.
Ti_MSMC_sF = function(i,n) {
  return ( -log(1-i/n) * GEN / MU / scaleFactor)
}
nmax = 200
t1vals = rep(0, nmax)
nvals = rep(0, nmax)
# find T1...
for (n in 1:nmax) {
  t1vals = append(t1vals, abs(Ti_MSMC_sF(1,n) - T1_PSMC) )
  nvals = append(nvals, n)
}
df = data.frame(nvals, t1vals)
df
