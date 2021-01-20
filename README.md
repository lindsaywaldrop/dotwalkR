# DotWalkR - an evolutionary simulation

DotWalkR is an evolutionary simulation that uses a Markov Chain Monte Carlo to `walk' simulated animals (dots) through a parameter space. Each axis represents an orthogonal parameter. The performance of the species in the parameter space is a function of the position of the animal in the space (a scalar function). 

The change in position during each time step (deltaf) is determined by two elements:
 * Directional selection is imposed on the animals to force them to climb the gradient:
    `k.*walktowards*beta(n,:).*dt`
    where k is the selection-heritability coefficient, walktowards specifies walking up or down the gradient, beta is the gradient at the positions of the dots, and dt is the time step.
 * Randomness is injected by adding a pseudo-random number multiplied by 
     `randscale.*((1-A %*% [1;1;1]).*M*dt)`
    where randscale is a scaling factor, A is a matrix determined by Sobol Indices, and M is a set of pseudo-random numbers.
    
The scalar functions themselves are based on a 21x21x21 matrix of output values, representing a downsampled gPC surrogate function. In order to estimate the gradient of the scalar function at each dot's position, produce_surrogate_fxn.m produces a MATLAB interpolant using scatteredInterpolant: https://www.mathworks.com/help/matlab/ref/scatteredinterpolant.html 

Producing and loading the interpolant is a time-consuming process producing very large files (over 200 MB), but it is reasonably fast after the initial time sink. 

## Required packages
These are the current required packages that must be installed before running DotWalkR: 
 * R.matlab
 * data.table
 * doParallel
 * foreach

## How to run
The code is working, however, it is incomplete as of now. But if you'd like to play around with the code, feel free to:  
 1. Change the default parameters in ./data/parameter-files/parameters-template. Each parameter name should be separated by a single space from its value. Currently, please leave test = TRUE. Valid choices for surrogate.name are clcd and clvz. You're welcome to change the number of cores to run the program on (copl) but it will automatically run on all available cores if this number is too big.
 2. Run the main program by entering in the R console: 
 `> source("./src/dotwalkr.R")`
 
## Parameter values in parameter-template

 * `n` is the number of lineages (dots) to evolve (walk)
 * `init.x` is the initial x position of the dots
 * `init.y` is the initial y position of the dots
 * `init.z` is the initial z posiiton of the dots
 * `dN` is the number of the nearest neighbors that will be used to calculate a weighted mean of the surrogate value based on each point. (Suggested that you do not change this.)
 * `end.time` is the number of generates that the simulation will run for. 
 * `delta.t` is the time step. (Suggested that you do not change this.)
 * `walktowards` is a value that will assign a direct to the motion relative to the gradient. Positive 1 will make the dots walk up the gradient and negative one will make the dots walk down the gradient. (Suggested you do not change this for now.)
 * `k` is the heritability or strength of selection parameter. Lower values will make the steps taken based on the gradient of the surrogate smaller, higher values will make them larger. 
 * `t.save.interval` is the number of time steps you'd like to set between when the dot data are saved. 
 * `copl` is the number of cores to use in parallel. For running sequentially, set to 1. If this value is larger than the number of available cores, the simulation will run on the number of the available cores. 
 * `test` is a logical parameter to indicate whether or not the simulation is in test mode. Please leave TRUE for now. 
 * `surrogate.name` is the name of the surrogate value that you'd like to use for the simulation. Current valid values are clcd and clvz. 
 
 The output is csv files that record the x, y, z positions and surrogate value of each dot (lineage) in the simulation.