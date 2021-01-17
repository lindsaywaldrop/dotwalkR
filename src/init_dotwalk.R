# Loading required libraries
library(R.matlab)
library(data.table)

# Loading source code
source("./src/functions/NearestNeighbor.R")
source("./src/functions/reshape_functions.R")

# Loading input data 
source("./src/loadMatData.R")

# Setup 
n <- 100  # Number of dots
init.x <- 5.5  # Initial x position of dots
init.y <- 0.1  # Initial y position of dots
init.z <- 105000  # Initial z position of dots

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


