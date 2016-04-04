#!/bin/bash
#SBATCH -p batch            	# partition (this is the queue your job will be added to) 
#SBATCH -N 1               	# number of nodes (due to the nature of sequential processing, here uses single node)
#SBATCH -n 2              	# number of cores (here uses 2)
#SBATCH --time=01:00:00    	# time allocation, which has the format (D-HH:MM), here set to 1 hour
#SBATCH --mem=32GB         	# memory pool for all cores (here set to 32 GB)

# Notification configuration 
#SBATCH --mail-type=END					    	# Type of email notifications will be sent (here set to END, which means an email will be sent when the job is done)
#SBATCH --mail-type=FAIL   					# Type of email notifications will be sent (here set to FAIL, which means an email will be sent when the job is fail to complete)
#SBATCH --mail-user=firstname.lastname@adelelaide.edu.au  	# Email to which notification will be sent

# Executing script (Example here is sequencial script and you have to select suitable compiler for your case.)
bash ./my_program.sh 		# bash script used here for an example, you should select proper compiler for your needs 
