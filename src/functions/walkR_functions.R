# DotWalkR functions

register.backend <- function(copl, windows = FALSE) {
  co <- detectCores()
  if (windows == TRUE) {
    if (copl > co ) {
      cluster <- makePSOCKcluster(co)
      message("Cores requested exceed the number available, using max detected.")
    } else {
      cluster <- makePSOCKcluster(copl)
    }
    return(cluster)
  } else {
    if (copl > co ) {
      registerDoParallel(cores = co)
      message("Cores requested exceed the number available, using max detected.")
    } else {
      registerDoParallel(cores = copl)
    }
    return(NULL)
  }
}

load.matdata <- function(surrogate.type, data.type, example = TRUE, test = FALSE){
  # Loading function which sets up matlab data in correct type. Specific naming structure 
  # for mat files required!
  require(R.matlab)
  if (test == TRUE) {
    folder.loc <- "./tests/testdata/"
    surrogate.type <- paste(surrogate.type, "_resampled_", sep = "")
    data.type <- paste(data.type, "_long", sep = "")
    tmp.ext <- ".mat"
  } else if (test == FALSE && example == TRUE) {
    folder.loc <- paste("./data/example-data/", surrogate.type, "/", sep = "")
    surrogate.type <- paste(surrogate.type, "_resampled_", sep = "")
    data.type <- paste(data.type, "_long", sep = "")
    tmp.ext <- ".mat"
  } else {
    folder.loc <- paste("./data/", surrogate.type, "/", sep = "")
    surrogate.type <- paste(surrogate.type, "_", sep = "")
    tmp.ext <- ".mat"
  }
  if (data.type == "input" || data.type == "input_long") {
    mat.data <- readMat(paste(folder.loc, surrogate.type, data.type, tmp.ext, sep = ""))
    data <- mat.data[["input"]]
  } else if (data.type == "SI" || data.type == "SI_long") {
    tmp.type <- strsplit(surrogate.type, "_")
    surrogate.type <- tmp.type[[1]][1]
    SI.data <- readMat(paste(folder.loc, surrogate.type, "_SI", tmp.ext, sep = ""))
    A<-SI.data[["A"]]
    data<-as.matrix(A) 
  } else if (data.type == "surrogate" || data.type == "surrogate_long") {
    mat.data <- readMat(paste(folder.loc, surrogate.type, data.type, tmp.ext, sep = ""))
    data.name <- "fmat"
    data<-mat.data[[data.name]]
  }  else {
    mat.data <- readMat(paste(folder.loc, surrogate.type, data.type, tmp.ext, sep = ""))
    data.name <- strsplit(data.type, "_")
    data.name <- data.name[[1]][1]
    data<-mat.data[[data.name]]
  }
  if(is.null(data)) stop("Unexpected structure to MATLAB file, look again at the names of child objects!")
  return(data)
}

scale.dots <- function(dots, x.range, y.range, z.range){
  # Reshapes 3D positions of dots based on ranges provided.
  if (class(dots)[1] != "matrix") stop("dots must be a matrix")
  if (length(x.range) != 2 && class(x.range) != "numeric") {
    stop("x.range must be a vector with two values, try using range()")
  }
  if (length(y.range) != 2 && class(y.range) != "numeric") {
    stop("y.range must be a vector with two values, try using range()")
  }
  if (length(z.range) != 2 && class(z.range) != "numeric") {
    stop("z.range must be a vector with two values, try using range()")
  }
  if (is.null(dim(dots))) {
    dots.size <- as.numeric(length(dots))
    dots.scaled <- rep(NA, length = dots.size)
    dots.scaled[1] <- (dots[1] - x.range[1])/(x.range[2] - x.range[1])
    dots.scaled[2] <- (dots[2] - y.range[1])/(y.range[2] - y.range[1])
    dots.scaled[3] <- (dots[3] - z.range[1])/(z.range[2] - z.range[1])
  } else {
    dots.size <- dim(dots)
    dots.scaled <- matrix(data = NA, nrow = dots.size[1], ncol = dots.size[2])
    dots.scaled[,1] <- (dots[,1] - x.range[1])/(x.range[2] - x.range[1])
    dots.scaled[,2] <- (dots[,2] - y.range[1])/(y.range[2] - y.range[1])
    dots.scaled[,3] <- (dots[,3] - z.range[1])/(z.range[2] - z.range[1])
  }
  return(dots.scaled)
}

save.dots <- function(folder.name, dots, time.now){
  # Saves dot file at specified time. 
  require(data.table)
  if(sum(is.na(dots)) != 0) warning("Dots contain NA values!!")
  filename <- paste(folder.name, "/dots_",time.now,".csv", sep = "")
  fwrite(data.frame(dots), file = filename, append = TRUE, sep = " ", nThread = 2)
}

getMeanValue <- function(vectors, values, testVector, desiredNeighbors) {
  # Gets mean surrogate value from the number of nearest-neighbor points. Mean
  # is a weighted average based on the distance of the points.
  require(data.table)
  require(parallel)
  require(doParallel)
  require(foreach)
  if (class(testVector)[1] != "matrix") stop("testVector must be a matrix")
  if (class(vectors)[1] != "matrix") stop("vetors must be a matrix")
  if (class(desiredNeighbors) == "numeric") {
    desiredNeighbors <- as.integer(desiredNeighbors)
  } else if(class(desiredNeighbors) == "integer"){
  } else {
    stop("desiredNeighbors must be an integer or numeric")
  }
  means1<-foreach(i=1:dim(testVector)[1]) %dopar% {
    distances <- matrix(data = NA, nrow = dim(vectors)[1], ncol = 2)
    colnames(distances) <- c("index","distance")
    distances[, 1] <- seq(1:dim(vectors)[1])
    distances[, 2] <- sqrt((vectors[, 1] - testVector[i, 1])^2 +
                             (vectors[, 2] - testVector[i, 2])^2 +
                             (vectors[, 3] - testVector[i, 3])^2)
    distances2 <- as.data.table(distances)
    sorted.distances <- setkey(distances2, "distance")
    #final.dist<- sorted.distances[1:desiredNeighbors, ]
    #final.dist$wgts <- 1 - 20*(sorted.distances[1:desiredNeighbors, 2])
    #final.dist$value <- values[final.dist$index]
    #means[i] <- weighted.mean(as.numeric(final.dist$value), final.dist$wgts)
    idx <- sorted.distances[1:desiredNeighbors, ]
    wgts <- 1 - 20*(idx$distance)
    value <- values[idx$index]
    weighted.mean(as.numeric(value), wgts)
  }
  means<-unlist(means1)
  return(means)
}

find.betas <- function(dots, gradX, gradY, gradZ, input.real, input.scaled, dN, delta.t){
  scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                            range(input.real[, 2]), 
                            range(input.real[, 3]))
  dx <- getMeanValue(input.scaled, gradX, scaled.dots, dN)
  dy <- getMeanValue(input.scaled, gradY, scaled.dots, dN)
  dz <- getMeanValue(input.scaled, gradZ, scaled.dots, dN)
  beta<-matrix(data = c(dx,dy,dz), ncol = 3)
  return(beta)
}



generaterandM <- function(n){
  a=-1;  
  b=1;
  M = (b-a)*runif(n)+a
}

herd.dots <- function(dots, position, range.dots){
  escaped.low <- which(dots[,position]<range.dots[1])
  escaped.high <- which(dots[,position]>range.dots[2])
  if (length(escaped.low)>0) {
    dots[escaped.low,position] <- range.dots[1]
  }
  if (length(escaped.high)>0) {
    dots[escaped.high,position] <- range.dots[2]
  }
  return(dots)
}

