"""
takes a .psmcfa file as input, find the N largest contigs, and puts them into a new file

findNLargestContigs.py N infile.psmcfa
"""

#####

"""
PSEUDOCODE:

Take value of N from the command.
Store infile.psmcfa as a variable.

Create an object (which we will call "object") with the following form:

contigName   length   startLine endLine
c1           95
c2           4000
c3           595
...

etc. it'll be empty for now though. If necessary, might need to see how many times ">" comes up, that'll be the long dimension of the object. The column "length" is actually bp * 100 (and probably will not be exactly the same as MSMC due to bin round at the end, but should be close enough).

Might also need to store the position (line number) of each contig header. Shaun has a script which counts contig LINES (reorderContigs.py), which isn't quite the same but might do for now?

For each contig (i in 0 : num of contigs - 1)
  Store the contig name, i.e. >Contig1.G5, as position object$contigName[i]
  Count the number of characters in that contig. Stop counting when it hits the next contig.
  
Now order object, descending by length. Call this "objectOrdered". Create a text file called infileOrdered.psmcfa

contigName   length   startLine   endLine
c25          100000
c4           55944
c100         59490
...

Now throw out everything in objectOrdered not in the top 50 longest. Now reorder objectOrdered > objectOrdered2 by startLine.

For (i in objectOrdered2$contigName)
  Go to the line of object$contigName[i]
  To infile.Ordered.psmcfa, append with the first line (header), second line (data), third line (data) etc. until the end of that contig (can use startLine and endLine in object).
  Pointer keeps on going until it finds header i+1 etc.

Done!
"""

#####

# read arguments in
import sys
if len(sys.argv)==3:
    N=int(sys.argv[1])
    filename=sys.argv[2]
else:
    print("The correct syntax is: 'python3 findNLargestContigs.py N infile.psmcfa'")

#print(filename, N, "\n")

# create object
import numpy as np
import pandas as pd

contigName=[]
length=[]
startLine=[]
endLine=[]

with open(filename) as infile: # uses python 3 to call lines from a file without having to load the whole thing into memory.
    j=0
    numChars=0
    # find position and name of all ">" (headers for contigs)
    # find where contigs start
    for line in infile: # loop over each line in infile
        if ">" in line:
            contigName.append(line)
            startLine.append(j)
            if j!=0: # don't append on the first line
                length.append(numChars)
                numChars=0 # reset for the next contig
        else: # if not a header line, count how many characters are in the contig
            for char in line:
                if char == 'K':
                    numChars=numChars+1
                elif char == 'T':
                    numChars=numChars+1
                elif char == 'N':
                    numChars=numChars+1
        j=j+1
# sort out endLine
for i in range(0,len(startLine)-1):
    endLine.append(startLine[i+1]-1)
endLine.append(j-1) # so it has the same index 0 counting method

# sort out last contig length
length.append(numChars)

# checking stuff (note using a 0 index)
#print("Contig Names:",contigName)
#print("Contig Start Lines:",startLine)
#print("Contig End Lines:",endLine)
#print("Contig Lengths:",length)

# combine lists
object = pd.DataFrame({'contigName' : contigName,
                       'length' : length,
                       'startLine' : startLine,
                       'endLine': endLine})
#print("object:\n",object)

objectOrdered = pd.DataFrame.sort(object,columns='length',ascending=False) # sort by length in descending order
#print("objectOrdered:\n",objectOrdered)

#print(objectOrdered.length[N],"\n",objectOrdered.startLine,"\n",objectOrdered.endLine)

# now cut off everything below the N you want

objectOrdered2 = objectOrdered[:N]
#print("objectOrdered2:\n",objectOrdered2)
objectOrdered2 = pd.DataFrame.sort(objectOrdered2,columns='startLine',ascending=True) # sort by startLine in ascending order
print("objectOrdered2:\n",objectOrdered2)

"""
For (i in objectOrdered2$contigName)
  Go to the line of object$contigName[i]
  To infile.Ordered.psmcfa, append with the first line (header), second line (data), third line (data) etc. until the end of that contig (can use startLine and endLine in object).
  Pointer keeps on going until it finds header i+1 etc.
"""

# create new file
# new file name: infile.NLargestContigs.psmcfa. Need to construct this name.
import re # regular expressions. re.sub: substitute . \. means actuaally match a dot, $ means right side of line, replace with "" i.e. nothing, get from infile which shuld be of form "devil.psmcfa"
prefix = re.sub(r"\.psmcfa$","",filename)
#print(prefix,"\n")
# %s: string. $02d: pad with 0s, 2 digits, decimal number (?)
outfile = "%s%02d%s"%(prefix,N,"LargestContigs.psmcfa")
#print(outfile,"\n")
f = open(outfile, 'w')

with open(filename) as infile: # uses python 3 to call lines from a file without having to load the whole thing into memory.

    # where we want to start from...
#    header=objectOrdered2.contigName[0]
    c=0 # contig counter
#    print(objectOrdered2.startLine[objectOrdered2.index[c]])
    begin=objectOrdered2.startLine[objectOrdered2.index[c]] # for some reason, the indexing is weird now...
    end=objectOrdered2.endLine[objectOrdered2.index[c]]

    l=0 # line counter

    for line in infile: # loop over each line in infile
        if (l>=begin and l<=end):
            f.write(line) # write relevant lines to new file f

        l=l+1
        #     print(c,"\n")
        if (l>end and c<N-1):
            c=c+1
            begin=objectOrdered2.startLine[objectOrdered2.index[c]]
            end=objectOrdered2.endLine[objectOrdered2.index[c]]

print("The largest",N,"contigs are contained in:",outfile)
