# Loading required libraries
library(R.matlab)
library(data.table)
library(parallel)
require(doParallel)
library(foreach)

# Loading source code functions
source("./src/functions/walkR_functions.R")

#### Loading parameters ####
if (exists("parameter.filename") == FALSE && exists("test") == FALSE){ 
  parameter.filename = "parameters-template"
  message("Using default parameter file!")
}

if (exists("test") && test == TRUE) {
  parameters <- read.table(parameter.filename, stringsAsFactors = FALSE)
} else {
  parameters <- read.table(paste("./data/parameter-files/", parameter.filename, sep = ""), stringsAsFactors = FALSE)
}
for(i in 1:dim(parameters)[1]) {
  if (parameters$V1[i] == "surrogate.name") {
    tmp <- parameters$V2[i]
  } else if (parameters$V1[i] == "test" || parameters$V1[i] == "windows" || parameters$V1[i] == "example" || parameters$V1[i] == "use.SI") {
    tmp <- as.logical(parameters$V2[i])
  }else {
    tmp<-as.numeric(parameters$V2[i])
  }
  assign(parameters$V1[i], tmp)
}

# Registering backend for parallel computing
if(test == FALSE) cluster <- register.backend(copl, windows)
if(test == TRUE && surrogate.name == "scaling") cluster <- register.backend(copl, windows)

# Loading input data 
#source("./src/loadMatData.R")
input.real <- load.matdata(surrogate.name, "input", example, test)
input.scaled<-scale.dots(input.real, range(input.real[, 1]), 
                         range(input.real[, 2]), range(input.real[, 3]))
surrogate <- load.matdata(surrogate.name, "surrogate", example, test)
gradX <- load.matdata(surrogate.name, "gradx", example, test)
gradY <- load.matdata(surrogate.name, "grady", example, test)
gradZ <- load.matdata(surrogate.name, "gradz", example, test)
if(use.SI == TRUE){
  A <- load.matdata(surrogate.name, "SI", example, test)
} else {
  A <- matrix(data=c(0.6666, 1, 1, 1, 0.6666, 1, 1, 1, 0.6666), ncol = 3)
}

# Defines scaling parameter for random movements 
if(surrogate.name == "constx" || surrogate.name == "consty" || surrogate.name == "constz"){
  randscale <- c(0, 0, 0)
} else {
  randscale <- c(0.0450, 1e-3, 950) 
}

#### Setup dots ####
# Creates dots at initial positions, value column initially NA
dots <- matrix(data=NA, nrow = n, ncol = 4)
colnames(dots) <- c("x","y","z","value")
dots[, 1] <- rep(init.x, length = n)
dots[, 2] <- rep(init.y, length = n)
dots[, 3] <- rep(init.z, length = n)

#### Setup results folder ####
if(test == TRUE) {
  dir.create("./tests/results", showWarnings = FALSE)
  if (surrogate.name == "scaling") {
    dir.create("./tests/results/scaling", showWarnings = FALSE)
    folder.name <- paste("./tests/results/scaling/cores", copl, "_npts", n, sep = "")
    dir.create(folder.name, showWarnings = FALSE)
  } else{
    folder.name <- paste("./tests/results/", surrogate.name, sep = "")
    dir.create(folder.name, showWarnings = FALSE)
    write.table(parameters, paste(folder.name, "/parameters_used", sep = ""), 
              sep = " ", quote = FALSE, col.names = FALSE, row.names = FALSE)
  }
} else {
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
}
