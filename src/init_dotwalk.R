# Loading required libraries
library(R.matlab)
library(data.table)
library(parallel)
require(doParallel)
library(foreach)

co <- detectCores()
registerDoParallel(cores=co)

# Loading source code functions
source("./src/functions/walkR_functions.R")
source("./src/functions/reshape_functions.R")

# Loading input data 
source("./src/loadMatData.R")

#### Setup dots ####
n <- 10000  # Number of dots
init.x <- 5.5  # Initial x position of dots
init.y <- 0.1  # Initial y position of dots
init.z <- 105000  # Initial z position of dots
dN <- 3
#### Defines parameters ####
end.time <- 5   # End simulation time in s
walktowards <- 1      # Sets the direction to follow the gradient, 1=up, -1=down
k <- 0.001                # Selection-heritability strength determinant
randscale <- c(0.0450, 1e-3, 950)
delta.t <- 1  # Time step size 
t.save.interval <- 0

# Creates dots at initial positions 
dots <- matrix(data=NA, nrow = n, ncol = 4)
colnames(dots) <- c("x","y","z","value")
dots[, 1] <- rep(init.x, length = n)
dots[, 2] <- rep(init.y, length = n)
dots[, 3] <- rep(init.z, length = n)


