# Plotting functions

plotdot <- function(run.name, t, interval, clr){
dots <- read.table(paste("./results/", run.name, "/dots_", t, ".csv", sep = ""), sep = " ", 
                   header = TRUE)
dots2 <- dots[seq(1, dim(dots_0)[1], by = interval),]
points(dots2$y, dots2$z, pch = 19, col = clr)
return(mean(as.numeric(dots$value), na.rm = TRUE))
}