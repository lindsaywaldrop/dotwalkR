# Loading matlab data
library(R.matlab)

source("./src/functions/NearestNeighbor.R")
source("./src/functions/reshape_functions.R")

# These are the 3D coordinates of the surrogate plot.
input.data <- readMat("./test/exampledata/input_resampled.mat")
# input.data[["input"]] is a 9261x3 matrix: [,1] is x, [,2] is y, and [,3] is z.
input.real<-input.data[["input"]]
input.scaled<-scale.dots(input.real,range(input.real[,1]), range(input.real[,2]), range(input.real[,3]))

# These are the values of the scalar surrogate plot.
fmat.data <- readMat("./test/exampledata/clcd_resampled_long.mat")
# fmat.data[["fmat"]] is a 9261x1 vector which are the scalar values, each row corresponds to the 3D
# coordinates in input.data[["input"]].
surrogate<-fmat.data[["fmat"]]

n<-100
test.dot<-matrix(data=NA, nrow = n, ncol = 3)
test.dot[,1] <-
  runif(n,
        min = min(input.data[["input"]][, 1]),
        max = max(input.data[["input"]][, 1]))
test.dot[,2] <-
  runif(n,
        min = min(input.data[["input"]][, 2]),
        max = max(input.data[["input"]][, 2]))
test.dot[,3] <-
  runif(n,
        min = min(input.data[["input"]][, 3]),
        max = max(input.data[["input"]][, 3]))

sample.dot<-scale.dots(test.dot, 
                       range(input.real[,1]), range(input.real[,2]), range(input.real[,3]))
##NN 1
#idxs<-list()
#mean.ps<-rep(NA, length=n)
#for (k in 1:length(sample.dot)){
#  idxs <- GetNeighbors(input.scaled, sample.dot[[k]], 3)
#  values<-rep(NA,3)
#  for (u in 1:3) values[u]<-surrogate[idxs[[u]]$index]
#  wgts <- 1 - 20*c(idxs[[1]]$distance, idxs[[2]]$distance, idxs[[3]]$distance)
#  mean.ps[k] <- weighted.mean(as.numeric(values), wgts)
#}

mean.ps<-rep(NA, length=n)
idxs<-getMeanValue(input.scaled, surrogate, sample.dot, 3)

  