#Reshape functions
load.matdata <- function(surrogate.type, data.type, test = FALSE){
  require(R.matlab)
  if (test==TRUE) {
    folder.loc <- "./test/exampledata/"
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
    data.type == "SI"
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
  return(data)
}

scale.dots <- function(dots, x.range, y.range, z.range){
  # Reshapes 3D positions of dots based on ranges provided.
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

save.dots <- function(folder.name, dots, t){
  filename <- paste(folder.name, "/dots_",t,".csv", sep = "")
  fwrite(data.frame(dots), file = filename, append = TRUE, sep = " ", nThread = 2)
}
