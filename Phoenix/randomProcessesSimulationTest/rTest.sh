#!/bin/bash
#SBATCH -p batch                    #Queue job will be added to
#SBATCH -N 1                        #Number of Nodes
#SBATCH -n 8                       #Number of Cores
#SBATCH --time=1:00:00           #Time length of code in (D-HH:MM:SS)
#SBATCH --mem=1GB                  #Memory allowed per cores

# NOTIFICATIONS
#SBATCH --mail-type=END             #If function finishes or fails, emails me
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alex,jackson@student.adelaide.edu.au


# RUNNING SCRIPT
# this one has the script with 1 million trials. On my laptop, it took
#real	3m46.794s
#user	3m46.436s
#sys	0m0.108s

# my script has times recorded inside
R --save < FULL_SYSTEM_SIMULATION.R > FSS_160319a_1million
