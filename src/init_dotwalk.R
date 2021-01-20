# Loading required libraries
library(R.matlab)
library(data.table)
library(parallel)
require(doParallel)
library(foreach)


# Loading source code functions
source("./src/functions/walkR_functions.R")
source("./src/functions/reshape_functions.R")

#### Loading parameters ####
if (exists("parameter.filename") == FALSE){ 
  parameter.filename = "parameters-template"
  message("Using default parameter file!")
}

parameters <- read.table(paste("./data/parameter-files/", parameter.filename, sep = ""), stringsAsFactors = FALSE)
for(i in 1:dim(parameters)[1]) {
  if (parameters$V1[i] == "surrogate.name") {
    tmp <- parameters$V2[i]
  } else if (parameters$V1[i] == "test") {
    tmp <- as.logical(parameters$V2[i])
  }else {
    tmp<-as.numeric(parameters$V2[i])
  }
  assign(parameters$V1[i], tmp)
}

# Registering backend for parallel computing
co <- detectCores()
if (copl > co ) {
  registerDoParallel(cores=co)
  message("Cores requested exceed the number available, using max detected.")
} else {
  registerDoParallel(cores=copl)
}

# Loading input data 
#source("./src/loadMatData.R")
input.real <- load.matdata(surrogate.name, "input", test = TRUE)
input.scaled<-scale.dots(input.real,range(input.real[,1]), range(input.real[,2]), range(input.real[,3]))
surrogate <- load.matdata(surrogate.name, "surrogate", test = TRUE)
gradX <- load.matdata(surrogate.name, "gradx", test = TRUE)
gradY <- load.matdata(surrogate.name, "grady", test = TRUE)
gradZ <- load.matdata(surrogate.name, "gradz", test = TRUE)
A <- load.matdata(surrogate.name, "SI", test = TRUE)

# Defines scaling parameter for random movements 
randscale <- c(0.0450, 1e-3, 950) 

#### Setup dots ####
# Creates dots at initial positions, value column initially NA
dots <- matrix(data=NA, nrow = n, ncol = 4)
colnames(dots) <- c("x","y","z","value")
dots[, 1] <- rep(init.x, length = n)
dots[, 2] <- rep(init.y, length = n)
dots[, 3] <- rep(init.z, length = n)

#### Setup results folder ####
folder.name.tmp <- paste("./results/run", Sys.Date(), sep = "_")
tmp.no <- 1
folder.name <- paste(folder.name.tmp, "_no", tmp.no, sep = "")
if(dir.exists("./results/") == FALSE) dir.create("./results/")
while(dir.exists(folder.name) == TRUE) {
    folder.name <- paste(folder.name.tmp, "_no", tmp.no, sep = "")
    tmp.no <- tmp.no + 1
  }
dir.create(folder.name)
rm(tmp.no, folder.name.tmp)

write.table(parameters, paste(folder.name, "/parameters_used", sep = ""), 
            sep = " ", quote = FALSE, col.names = FALSE, row.names = FALSE)

