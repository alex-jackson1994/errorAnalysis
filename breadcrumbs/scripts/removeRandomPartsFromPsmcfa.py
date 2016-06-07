#!/usr/bin/env python3
#USE: 'removeRandomPartsFromPsmcfa.py [inputFile.psmcfa] [probability=0.1] > [outputFile.psmcfa]
#This script removes random individual lines from a .psmcfa file. This is similar to removeRandomContigs.py, however this operates on individual lines not on whole contigs.
#The probability of removal is specified in the command line input
import sys
from random import random

if len(sys.argv)==3:
	filename=sys.argv[1] #take filename as a system argument
	probability=float(sys.argv[2])
elif len(sys.argv)==2:
	filename=sys.argv[1] #take filename as a system argument
	probability=0.1
else:
	sys.exit('The correct syntax is: ./binarySplitPsmcfa.py [filename] [probability=0.1]')

if probability<0 or probability>1:
	sys.exit("That's not a valid probability! Probabilities are between 0 and 1")
	
with open(filename) as infile: #uses python 3 to call lines from a file without having to load the whole thing into memory. 
	for line in infile: #loop over each line in the file
		x=random()
		if '>' in line:
			contigHeader=line
			startContig=1
			continue
		elif startContig==1:
			if x>=probability:
				print(contigHeader,end='')
				print(line,end='')
				startContig=0
				continue
		else:
			if x>=probability:
				print(line,end='')