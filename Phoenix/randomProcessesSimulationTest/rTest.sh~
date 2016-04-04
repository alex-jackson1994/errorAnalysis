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
# I want to run my print_scaled_matrix script in the ~/phoenixTesting folder.
./print_scaled_matrix > print_scaled_matrix.out
