#Reshape functions

#reshape.input <- function(input){
#  input.scaled<-scale.dots(input, range(input[,1]), range(input[,2]), range(input[,3]))
  #reshaped.input <- split(input.scaled, seq(as.numeric(dim(input)[1])))
#  return(reshaped.input)
#}

scale.dots<-function(dots,x.range,y.range,z.range){
  if (is.null(dim(dots))) {
    dots.size <- as.numeric(length(dots))
    dots.scaled <- rep(NA,length=dots.size)
    dots.scaled[1] <- (dots[1]-x.range[1])/(x.range[2]-x.range[1])
    dots.scaled[2] <- (dots[2]-y.range[1])/(y.range[2]-y.range[1])
    dots.scaled[3] <- (dots[3]-z.range[1])/(z.range[2]-z.range[1])
    #dots.scaled.list <- split(dots.scaled, as.numeric(1))
  } else {
    dots.size <- dim(dots)
    dots.scaled<-matrix(data=NA,nrow=dots.size[1],ncol=dots.size[2])
    dots.scaled[,1] <- (dots[,1]-x.range[1])/(x.range[2]-x.range[1])
    dots.scaled[,2] <- (dots[,2]-y.range[1])/(y.range[2]-y.range[1])
    dots.scaled[,3] <- (dots[,3]-z.range[1])/(z.range[2]-z.range[1])
    #dots.scaled.list <- split(dots.scaled, seq(as.numeric(dim(dots.scaled)[1])))
  }
  #return(dots.scaled.list)
  return(dots.scaled)
}
