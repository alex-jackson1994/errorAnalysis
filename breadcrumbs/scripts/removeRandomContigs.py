#!/usr/bin/env python3
#USE: 'removeRandomContigs.py [inputFile.psmcfa] [probability=0.1] > [outputFile.psmcfa]
#This script takes a input .psmcfa file and then removes random contigs from the file. The probability of removal (and hence rough frequency) is given
#as the command line argument probability (see above). The probability defaults to 0.1 if it is not specified. Note the probability is the removal frequency;
#hence 0.1 removes 10% of all contigs leaving 90% remaining.
import sys
from random import random

if len(sys.argv)==3:
	filename=sys.argv[1] #take filename as a system argument
	probability=float(sys.argv[2])
elif len(sys.argv)==2:
	filename=sys.argv[1] #take filename as a system argument
	probability=0.1
else:
	sys.exit('The correct syntax is: ./removeRandomContigs.py [filename] [probability=0.1]')

if probability<0 or probability>1:
	sys.exit("That's not a valid probability! Probabilities are between 0 and 1")

headers=[] # define some empty lists for use later
chromoLength=[]
lineOffset=[]
offset=0

with open(filename) as infile: #uses python 3 to call lines from a file without having to load the whole thing into memory. 
	j=0
	#This loop both finds the position of every line break and of each header
	for line in infile: #loop over each line in the file
		lineOffset.append(offset)# Read in the file once and build a list of line breaks, this will allow us to jump to the line we need in the file
		offset += len(line)
		if ">" in line:
			headers.append(j) #find the header of each new chromosome/contig/etc in the file
		j+=1
headers.append(j) #add the end of the file to the headers list

includeContig=[]
for j in range(0,len(headers)):
	x=random()
	if x>=probability:
		includeContig.append(1)
	else:
		includeContig.append(0)

with open(filename) as infile: #uses python 3 to call lines from a file without having to load the whole thing into memory. 
	j=0
	for line in infile: #loop over each line in the file
		if '>' in line:
			if includeContig[j]==0:
				infile.seek(lineOffset[headers[j+1]])
				j+=1
				continue
			j+=1
		print(line,end='')
			