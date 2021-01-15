# DotWalkR - an evolutionary simulation

DotWalkR is an evolutionary simulation that uses a Markov Chain Monte Carlo to `walk' simulated animals (dots) through a parameter space. Each axis represents an orthogonal parameter. The performance of the species in the parameter space is a function of the position of the animal in the space (a scalar function). 

The change in position during each time step (deltaf) is determined by two elements:
 * Directional selection is imposed on the animals to force them to climb the gradient:
    `k.*walktowards*beta(n,:).*dt`
    where k is the selection-heritability coefficient, walktowards specifies walking up or down the gradient, beta is the gradient at the positions of the dots, and dt is the time step.
 * Randomness is injected by adding a pseudo-random number multiplied by 
     `randscale.*((1-A)*[1;1;1]).*M*dt)`
    where randscale is a scaling factor, A is a matrix determined by Sobol Indices, and M is a set of pseudo-random numbers.
    
The scalar functions themselves are based on a 201x201x201 matrix of output values, representing a gPC surrogate function. In order to estimate the gradient of the scalar function at each dot's position, produce_surrogate_fxn.m produces a MATLAB interpolant using scatteredInterpolant: https://www.mathworks.com/help/matlab/ref/scatteredinterpolant.html 

Producing and loading the interpolant is a time-consuming process producing very large files (over 200 MB), but it is reasonably fast after the initial time sink. I'd like to find a function that either does something similar in R as scatteredInterpolant or does a nearest-neighbor search with a linear interpolation of the scalar function between the nearest grid points. This might need to be exported to C, although I haven't though enough about it to have an opinion at this point. 

## How to run
The code is working, however, the data files are too big to put on github. To run the simulation, you would: 
 1. Run produce_surrogate_fxn.m, which would produce the interpolants needed to run the function.
 2. Run initWalkDots.m which defines initial parameters and calls walkUrDots function, which is in walkUrDots.m. 
 
 The output is csv files that record the x, y, and z positions of each dot (animal) in the simulation.