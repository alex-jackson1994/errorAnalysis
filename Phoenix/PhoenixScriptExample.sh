#!/bin/bash
#SBATCH -p batch                    #Queue job will be added to
#SBATCH -N 1                        #Number of Nodes
#SBATCH -n 16                       #Number of Cores
#SBATCH --time=5-00:00:00           #Time length of code in (D-HH:MM:SS)
#SBATCH --mem=16GB                  #Memory allowed per cores

# NOTIFICATIONS
#SBATCH --mail-type=END             #If function finishes or fails, emails me
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=lachlan.bubb@student.adelaide.edu.au


# RUNNING SCRIPT
matlab -nodisplay -r "PhoenixFunction" >PhoenixFunction_output.log


