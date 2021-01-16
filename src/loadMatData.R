# Loading matlab data
library(R.matlab)

source("./src/functions/NearestNeighbor.R")

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

test.dot<-c(10.11, 0.19866, 117500)
test.dot<-matrix(data=NA, nrow = 10, ncol = 3)
test.dot[1,] <-  c(10.11, 0.19866, 117500)
test.dot[2,] <- c(7.98, 0.09866, 107534)
test.dot[3,] <- c(4.11, 0.166, 75000)
test.dot[4,] <- c(4.11, 0.166, 75000)
test.dot[5,] <- c(4.11, 0.166, 75000)
test.dot[6,] <- c(4.11, 0.166, 75000)
test.dot[7,] <- c(4.11, 0.166, 75000)
test.dot[8,] <- c(4.11, 0.166, 75000)
test.dot[9,] <- c(4.11, 0.166, 75000)
test.dot[10,] <- c(4.11, 0.166, 75000)

sample.dot<-scale.dots(test.dot, 
                       range(input.real[,1]), range(input.real[,2]), range(input.real[,3]))
idxs<-list()
mean.ps<-rep(NA, length=10)
for (k in 1:length(sample.dot)){
  idxs <- GetNeighbors(input.scaled, sample.dot[[k]], 3)
  idxs.df <- data.frame(input.real[idxs[[1]]$index,], 
                             input.real[idxs[[2]]$index,], 
                             input.real[idxs[[3]]$index,])
  values.df <- data.frame(surrogate[idxs[[1]]$index], 
                          surrogate[idxs[[2]]$index], 
                          surrogate[idxs[[3]]$index])
  wgts <- 1 - 20*c(idxs[[1]]$distance,idxs[[2]]$distance, idxs[[3]]$distance)
  mean.ps[k] <- weighted.mean(as.numeric(values.df), wgts)
}



plot(input.real[,1],input.real[,2])
points(test.dot[1],test.dot[2],pch=19,col="blue")
points(idxs.df[1,],idxs.df[2,],pch=19,col="red")
print(values.df)


mean.ps <- weighted.mean(as.numeric(values.df), wgts)
resid.ps <- mean.ps - as.numeric(values.df)
  
  