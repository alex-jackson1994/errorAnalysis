#!/bin/bash
#USE: 'removeDataFromPSMC.sh [inputFile.psmc] > [outputFile.txt]
#this scripts removes the useful data from the last iteration of a PSMC run.
#Given a *.psmc file in on the command line and this prints a tab delimited table of the data from the psmc run

#This first line just outputs the header of the columns
echo 'k	t_k	lambda_k	sigma_k	\sum_{l\not=k}A_{kl}	A_{kk}'

#this line fines how many time intervals were used in the PSMC run
#by grepping for every lines with an RS in it, which is how PSMC denotes data
#lines, then taking only the last line, since that's where we need to grab the
#number of intervals from, then returns the second column value, which is what 
#we want
numOfDataPoints=$(grep 'RS' $1 | tail -n 1 | cut -f2)

#then we again take all the RS lines, take the right number of lines off the end
#and lastly cut out the first column which has the RS in it
grep 'RS' $1 | tail -n "$numOfDataPoints" | cut -f2-

