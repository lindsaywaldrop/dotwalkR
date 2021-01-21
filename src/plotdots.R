library(viridis)

source("./src/functions/plot_functions.R")

run.name <- "run_2021-01-20_no4"
surrogate.name <- "CL at Vzmin"
n <- 10000
dt <- 100
interval <- 1
dots_0 <- read.table(paste("./results/", run.name, "/dots_0.csv", sep = ""), sep = " ", header = TRUE)
clr<-viridis(n/dt+1, option = "C")
par(mar=c(4,4,0.5,1),fig=c(0,1,0.3,1),new=TRUE)
plot(dots_0$x[1], dots_0$y[1], xlim = c(3, 12), ylim = c(0.0, 0.2), 
     xlab = "AR", ylab = "Camber")
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
mean(as.numeric(dots_end$value))

par(mfrow = c(1, 1))
plot(dots_end$x, dots_end$y)

boxplot(data.frame(dots_0$value, dots_end$value))
