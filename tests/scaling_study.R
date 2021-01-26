##### Scaling study for parallel computing ####

assign("parameter.filename", "./tests/testdata/parameters-scaling", envir = .GlobalEnv)
assign("test", is.logical(TRUE))
assign("windows", is.logical(FALSE))
copls <- c(1, 2, 4, 8, 16, 24)
ns <- c(10, 100, 1000, 10000, 100000)

savemytime <- matrix(data = NA, ncol = 5, nrow = (length(copls)*length(ns))) 
numbers<- seq(1:(length(copls)*length(ns)))
core.num <- rep(NA, length = (length(copls)*length(ns)))
point.num <- rep(NA, length = (length(copls)*length(ns)))

colnames(savemytime) <- c("user.self", "sys.self", "elapsed", "user.child", "sys.child")

for (boop in 1:length(copls)){
  copl <- copls[boop]
  for (bop in 1:length(ns)){
    n <- ns[bop]
    core.num[(5*(boop-1)+bop)] <- copl
    point.num[(5*(boop-1)+bop)] <- n
    print(paste("copl = ", copl, ", n = ", n, sep = ""))
    #savemytime[(5*(i-1)+j),] <-system.time(source("./src/dotwalkr.R"))
    temp.time <- system.time(source("./src/dotwalkr.R"))
    savemytime[(5*(boop-1)+bop),] <- as.numeric(temp.time)
  }
}

scaling.data <- data.frame("num" = numbers, savemytime, "cores" = core.num, "points" = point.num)

write.csv(scaling.data, file = "./tests/results/scaling/scaling_data.csv")


# For plotting with ggplot2
#scaling.data$points<-as.factor(scaling.data$points)
#scaling.data$cores<-as.factor(scaling.data$cores)
#ggplot(scaling.data, aes(cores, elapsed, color=points,group=points)) + geom_point() +geom_line()
#ggplot(scaling.data, aes(points, elapsed, color=cores,group=cores)) + geom_point() +geom_line() +
#  scale_y_continuous(trans='log2')
