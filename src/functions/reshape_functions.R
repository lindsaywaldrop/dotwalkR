#Reshape functions

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

save.dots <- function(dots, t){
  filename <- paste("./results/dots_",t,".csv", sep = "")
  fwrite(data.frame(dots), file = filename, append = TRUE, sep = " ", nThread = 2)
}
