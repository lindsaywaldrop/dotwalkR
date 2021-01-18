# Loading required libraries
library(R.matlab)
library(data.table)

# Loading source code
source("./src/functions/NearestNeighbor.R")
source("./src/functions/reshape_functions.R")

# Loading input data 
source("./src/loadMatData.R")

#### Setup dots ####
n <- 100  # Number of dots
init.x <- 5.5  # Initial x position of dots
init.y <- 0.1  # Initial y position of dots
init.z <- 105000  # Initial z position of dots
dN <- 3
#### Defines parameters ####
D <- 1e-8        # Diffusion coefficient in m^2/s
delta.t <- 1e-5  # Time step size in s
end.time <- 0.0001    # End simulation time in s
walktowards <- 1      # Sets the direction to follow the gradient, 1=up, -1=down
k <- 0.01;                # Selection-heritability strength determinant
randscale <- c(1,1,1) #=[0.0450;1e-3;950];
B <- c(0.5, 0.25, 0.25, 0.25, 0.5, 0.25, 0.25, 0.25, 0.5)
a <- c(1, 0, 0, 0, 1, 0, 0, 0, 1)
A <- matrix(a, ncol = 3, nrow = 3)
t.save.interval <- 0

# Creates dots at initial positions and finds surrogate values for each
dots <- matrix(data=NA, nrow = n, ncol = 4)
colnames(dots) <- c("x","y","z","value")
dots[, 1] <- rep(init.x, length = n)
dots[, 2] <- rep(init.y, length = n)
dots[, 3] <- rep(init.z, length = n)

scaled.dots <- scale.dots(dots, 
                       range(input.real[, 1]), 
                       range(input.real[, 2]), 
                       range(input.real[, 3]))

dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)

