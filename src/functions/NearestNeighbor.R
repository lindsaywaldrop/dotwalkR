Norm <- function(u, v, dimension = NULL) {
  if (is.null(dimension)) {
    dimension <- length(u)
  }
  innerProduct <- 0.
  for (i in 1:dimension) {
    innerProduct <- innerProduct + (u[[i]] - v[[i]]) ^ 2
  }
  return(sqrt(innerProduct))
}

GetNeighbors <- function(vectors, testVector, desiredNeighbors) {
  require(rlist)
  distances = list()
  for (i in 1:length(vectors)) {
    distances[[i]] <-
      list(
        vector = vectors[[i]],
        distance = Norm(testVector, vectors[[i]]),
        index = i
      )
  }
  sortedDistances <- list.sort(distances, distance)
  
  neighbors <- list()
  for (i in 1:desiredNeighbors) {
    neighbors[[i]]<-list()
    neighbors[[i]][["index"]] <- sortedDistances[[i]]$index
    neighbors[[i]][["distance"]] <- sortedDistances[[i]]$distance
  }
  return(neighbors)
}

getMeanValue <- function(vectors, values, testVector, desiredNeighbors) {
  # Gets mean surrogate value from the number of nearest-neighbor points. Mean
  # is a weighted average based on the distance of the points. 
  require(data.table)
  if (class(testVector)[1] != "matrix") stop("testVector must be a matrix")
  if (class(vectors)[1] != "matrix") stop("vetors must be a matrix")
  if (class(desiredNeighbors) == "numeric") {
    desiredNeighbors <- as.integer(desiredNeighbors)
  } else if(class(desiredNeighbors) == "integer"){
  } else {
    stop("desiredNeighbors must be an integer or numeric")
  }
  means<-rep(NA, length = dim(testVector)[1])
  for (i in 1:dim(testVector)[1]) {
    distances <- matrix(data = NA, nrow = dim(vectors)[1], ncol = 2)
    colnames(distances) <- c("index","distance")
    distances[, 1] <- seq(1:dim(vectors)[1])
    distances[, 2] <- sqrt((vectors[, 1] - testVector[i, 1])^2 +
                        (vectors[, 2] - testVector[i, 2])^2 + 
                        (vectors[, 3] - testVector[i, 3])^2)
    distances2 <- data.table(distances)
    sorted.distances <- setkey(distances2, "distance")
    final.dist<- sorted.distances[1:desiredNeighbors, ]
    final.dist$wgts <- 1 - 20*(sorted.distances[1:desiredNeighbors, 2])
    final.dist$value <- values[final.dist$index]
    means[i] <- weighted.mean(as.numeric(final.dist$value), final.dist$wgts)
  }
  return(means)
}

find.betas <- function(dots, gradX, gradY, gradZ, input.real, input.scaled, delta.t){
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

