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
    neighbors[[i]] <- sortedDistances[[i]]$index
  }
  return(neighbors)
}
