setwd("~/Documents/Summer Scholarship/RScripts/mshotlitePopulationChanges/")

eval_popsize = function(pos, x, y){ 
  xIndex = length(which(x <= pos))
  return(y[xIndex])
}

absdifference = function(xpos,func1x,func1y,func2x,func2y){
  #out=vector()
  out=NULL
  for (i in 1:length(xpos)) {
    out[i] = abs(eval_popsize(xpos[i],func1x,func1y) - eval_popsize(xpos[i],func2x,func2y))
  }
  return(out)
}

slidingWindow=function(xVals1,yVals1,xVals2,yVals2){
  xMin=max(min(xVals1),min(xVals2))
  xMax=min(max(xVals1),max(xVals2))
  xIntegralValues=seq(xMin,xMax,length=1000)
  integrationVal=vector()
  for(i in 1:(length(xIntegralValues)-1)){
    integrationReturn=integrate(absdifference,xIntegralValues[i],xIntegralValues[i+1], func1x=xVals1, func1y=yVals1, func2x=xVals2, func2y=yVals2, subdivisions=100)
    integrationVal[i]=integrationReturn$value
  }
  xCentredValues=(xIntegralValues[-1]+xIntegralValues[-length(xIntegralValues)])/2
  returnedValues=data.frame()
  returnedValues=cbind(xCentredValues,integrationVal)
  colnames(returnedValues)=c("centredXValue","integrationValue")
  plot(xCentredValues,integrationVal,"s",log='x',xlab='Time in the past (N_0 generations ago)',ylab='Error')
  return(returnedValues)
}
system2('../../myScripts/removeDataFromPSMC.sh', args='10Mbp4PopChanges/fullData.psmcfa.psmc',stdout='10Mbp4PopChanges/psmcRun.txt')
fullData<-read.table('10Mbp4PopChanges/psmcRun.txt',header=T)
trueTimes<-c(1e-10,0.1,0.5,1,2)
truePopSize<-c(1,1.5,2,1.5,1)
slidingWindow(fullData$t_k,fullData$lambda_k,trueTimes,truePopSize)

plot(1/2*fullData$t_k,fullData$lambda_k,"s",log='x',xlab='Time in the past (N_0 generations ago)',ylab='Relative Population Size')
lines(4*trueTimes,truePopSize,'s',col='red')