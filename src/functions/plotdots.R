plotdot <- function(t, clr){
  dots <- read.table(paste("./results/dots_", t, ".csv", sep = ""), sep = " ", 
                     header = TRUE)
  points(dots$x, dots$y, pch = 19, col = clr)
  return(mean(as.numeric(dots$value), na.rm = TRUE))
}

library(viridis)

n <- 920
dt <- 10
dots_0 <- read.table("./results/dots_0.csv", sep = " ", header = TRUE)
clr<-viridis(n/dt, option="C")
par(mar=c(4,4,0.5,1),fig=c(0,1,0.3,1),new=TRUE)
plot(dots_0$x, dots_0$y, xlim = c(3, 12), ylim = c(0.0, 0.2), 
     xlab = "AR", ylab = "Camber")
mean.values <- rep(NA, length=((n/dt)+1))
mean.values[1]<-mean(as.numeric(dots_0$value), na.rm=TRUE)
for (i in 0:(length(mean.values)-1)) mean.values[i+1]<-plotdot(i*dt, clr[i])
time <-seq(0, n, by = dt)
par(mar=c(4,4,0.5,1),fig=c(0,1,0,0.3),new=TRUE)
plot(x = seq(0, n, by = dt), y = mean.values, type = "l",
     xlab = "Simulation Time", ylab = "Mean CLCD")
for (i in 1:length(mean.values)) points(x = time[i], y = mean.values[i], col=clr[i], pch=19)



dots_end <- read.table(paste("./results/dots_",n,".csv",sep=""), sep = " ", header = TRUE)
summary(dots_end)
mean(as.numeric(dots_end$value))

par(mfrow=c(1,1))
plot(dots_end$x,dots_end$y)

boxplot(data.frame(dots_0$value,dots_end$value))
