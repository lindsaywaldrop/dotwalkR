library(viridis)

source("./src/functions/plot_functions.R")
dots.end<-rep(NA,4)

run.name <- "run_2021-03-11_no11"
surrogate.name <- "COT"
n <- 300
dt <- 100
interval <- 1
dots_0 <- read.table(paste("./results/", run.name, "/dots_0.csv", sep = ""), sep = " ", header = TRUE)
clr<-viridis(n/dt+1, option = "C")
par(mar=c(4,4,0.5,1),fig=c(0,1,0.3,1),new=TRUE)
plot(dots_0$y[1], dots_0$z[1], xlim = c(0.4, 1), ylim = c(0.5, 2.0), 
     xlab = "CR", ylab = "Freq")
mean.values <- rep(NA, length = ((n/dt) + 1))
mean.values[1]<-mean(as.numeric(dots_0$value), na.rm = TRUE)
for (i in 0:(length(mean.values) - 1)) mean.values[i + 1] <- plotdot(run.name, i*dt, interval, clr[i + 1])
time <-seq(0, n, by = dt)
par(mar = c(4, 4, 0.5, 1), fig = c(0, 1, 0, 0.3), new = TRUE)
plot(x = seq(0, n, by = dt), y = mean.values, type = "l",
     xlab = "Simulation Time", ylab = paste("Mean",surrogate.name))
for (i in 1:length(mean.values)) points(x = time[i], y = mean.values[i], col=clr[i], pch = 19)



dots_end <- read.table(paste("./results/", run.name, "/dots_", n, ".csv", sep=""), 
                       sep = " ", header = TRUE)
summary(dots_end)
dots.end[1]<-mean(as.numeric(dots_end$value))

par(mfrow = c(1, 1))
plot(dots_end$x, dots_end$y, xlim = c(0.5, 10), ylim = c(0.4, 1.0), pch=19,
     xlab = "AR", ylab = "Camber")

boxplot(data.frame(dots_0$value, dots_end$value))
