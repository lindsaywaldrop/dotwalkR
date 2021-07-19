library(viridis)
library(ggplot2)

source("./src/functions/plot_functions.R")

run.name <- "run_2021-06-15_no11"
surrogate.name <- "Q"

n <- 1400
dt <- 100
interval <- 1

plot.new()
plot.results(run.name, surrogate.name, "y", "z", n, dt, interval)
plot.new()
plot.results(run.name, surrogate.name, "x", "y", n, dt, interval)
plot.new()
plot.results(run.name, surrogate.name, "x", "z", n, dt, interval)

plot.anim(run.name, surrogate.name, "x", "y", n, dt)
plot.anim(run.name, surrogate.name, "x", "z", n, dt)
plot.anim(run.name, surrogate.name, "y", "z", n, dt)

dots.end<-rep(NA,31)

dots_begin <- read.table(paste("./results/", run.name, "/dots_", n, ".csv", sep=""), 
                       sep = " ", header = TRUE)

dots_end <- read.table(paste("./results/", run.name, "/dots_", n, ".csv", sep=""), 
                       sep = " ", header = TRUE)
summary(dots_end)
dots.end[1] <- mean(as.numeric(dots_end$value))

par(mfrow = c(1, 1))
plot(dots_end$y, dots_end$z, xlim = c(0.4, 1), ylim = c(0.5, 2.0), 
     xlab = "CR", ylab = "Freq")

boxplot(data.frame(dots_0$value, dots_end$value))
