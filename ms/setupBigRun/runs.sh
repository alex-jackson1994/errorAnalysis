#!/bin/bash/

### this script is designed to loop through ms runs with many different conditions. It will generate and SAVE randoms seeds for each ms run, in order to be completely reproducable.

### set up variables

numPloid = 2 # We are interested in a single diploid genome.
numChrom = 1 # We are going to generate a mega-chromosome and split it up ourselves. We are NOT going to include the sex chromosomes.
theta =1340759 # Using Schiffels' value of mu = 1.25e-8 mutations/bp/gen, we then multiple by #bp ( = basePairsInLocus, which we will take as 2681518154 until an empirical sequence is found). This gives mu = 33.512, and as theta = 4 * N_0 * mu (and using N_0 = 10000), this gives us theta = 1340759.
rho = 374723 # I didn't find a value of r. So I've kinda reverse-engineered Schiffels' r from his "zig-zag simulation". If theta = 4 * N_0 * mu, and rho = 4 * N_0 * r, then rearranging gives r = rho * mu / theta. So plugging in Schiffels' values of rho, mu, and theta (presumably, mu still is 1.25e-8 * numBp in his, 10 million), this gives us r = 2000 * (1.25e-8 * e7) / 7156 = 3.49e-2 (per e7 bp). We have more bp than that though, so we divide by e7 and multiply by 2681518154 to give us r = 9.368. Finall, multiplying r by 4 * N_0 gives us rho = 374723. ### RHO AND THETA SHOULD BE CHECKED ###
basePairsInLocus = 2681518154 # I got this from the Wikipedia page https://en.wikipedia.org/wiki/Chromosome#Human_chromosomes, taking "Total" and subtracting the number of bp in the X and Y chromosomes.
time0 =  0
pop0 = 1 # We want N_0 = 10000, and as ms populations is in units of N_0, this is 1.
time1 = 0.03 # We want this event to happen at 30 000 years ago. Recalling ms time is in units of 4 * N_0 generations, and using 25 years per generation, this gives us time1 = 30000/(4 * N_0 * 25) = 0.03.
growthRate1 = 115.129 # ms goes in time from recent to ancient. We want an exponential growth from 1 at time 0.03 to 0.1 at time 0.05. If we shift time so 0.03 is at time 0 (hence 0.05 is at time 0.02), we can solve for the coefficients of an exponential growth model. (From the msHOT-lite command, 	 -G alpha  ( N(t) = N0*exp(-alpha*t) .  alpha = -log(Np/Nr)/t) For the model N(t) = A*e^(-kt), we obtain A = 1 and k = 115.129.
time2 = 0.05 # We want this even to happen at 50 000 years ago.
pop2 = 2 # We want N at this time to be 20000.

### set up random seeds. I think the best idea will be to have a "seeds" file for each different type of run (e.g. constant-bottleneck, constant etc.). This will be space-delimited, with three seeds per line and each line corresponding to a single run.
