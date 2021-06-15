# Plotting functions

load.matdata <- function(surrogate.type, data.type, example = TRUE, test = FALSE){
  # Loading function which sets up matlab data in correct type. Specific naming structure 
  # for mat files required!
  require(R.matlab)
  if (test == TRUE) {
    folder.loc <- "./tests/testdata/"
    surrogate.type <- paste(surrogate.type, "_resampled_", sep = "")
    data.type <- paste(data.type, "_long", sep = "")
    tmp.ext <- ".mat"
  } else if (test == FALSE && example == TRUE) {
    folder.loc <- paste("./data/example-data/", surrogate.type, "/", sep = "")
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
    tmp.type <- strsplit(surrogate.type, "_")
    surrogate.type <- tmp.type[[1]][1]
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
  if(is.null(data)) stop("Unexpected structure to MATLAB file, look again at the names of child objects!")
  return(data)
}

plot.results <- function(run.name, surrogate.name, ploton.x, ploton.y, n, dt, interval){
  require(viridis)
  if(surrogate.name == "COT" || surrogate.name == "Q"){
    axis.labels <- matrix(c("Wo","CR","Freq"),nrow=3,dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(0.1, 10, 0.4, 1.0, 0.5, 2.0),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  } else if (surrogate.name == "clcd" || surrogate.name == "clvz" || surrogate.name == "clcdclvz"){
    axis.labels <- matrix(c("AR", "Camber", "Re"),nrow=3, dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(3, 12,0, 0.2, 10000, 200000),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  }
  if(file.exists(paste("./results/", run.name, "/dots_0.csv", sep = ""))){
    dots_0 <- read.table(paste("./results/", run.name, "/dots_0.csv", sep = ""), 
                         sep = " ", header = TRUE)
  }else{
    dots_0 <- read.table(paste("../results/", run.name, "/dots_0.csv", 
                               sep = ""), sep = " ", header = TRUE)
  }
  dimsdots<-dim(dots_0)[1]
  clr <- viridis(n/dt+1, option = "C")
  par(mar = c(4, 4, 0.5, 1), fig = c(0, 1, 0.3, 1), new = TRUE)
  plot(dots_0[1,ploton.x], dots_0[1,ploton.y], xlim = axis.range[ploton.x,], ylim = axis.range[ploton.y,], 
       xlab = axis.labels[ploton.x,], ylab = axis.labels[ploton.y,])
  mean.values <- rep(NA, length = ((n/dt) + 1))
  mean.values[1] <- mean(as.numeric(dots_0$value), na.rm = TRUE)
  for (i in 0:(length(mean.values) - 1)) mean.values[i + 1] <- plotdot(run.name, ploton.x, ploton.y, i*dt, dimsdots, interval, clr[i + 1])
  time <- seq(0, n, by = dt)
  par(mar = c(4, 4, 0.5, 1), fig = c(0, 1, 0, 0.3), new = TRUE)
  plot(x = seq(0, n, by = dt), y = mean.values, type = "l",
       xlab = "Simulation Time", ylab = paste("Mean", surrogate.name))
  for (i in 1:length(mean.values)) points(x = time[i], y = mean.values[i], col = clr[i], pch = 19)
}

plotdot <- function(run.name, ploton.x, ploton.y, t, dimsdots, interval, clr){
  if (file.exists(paste("./results/", run.name, "/dots_", t, ".csv", sep = ""))){
    dots <- read.table(paste("./results/", run.name, "/dots_", t, ".csv", sep = ""), sep = " ", 
                       header = TRUE)
  } else {
    dots <- read.table(paste("../results/", run.name, "/dots_", t, ".csv", sep = ""), sep = " ", 
                       header = TRUE)
  }
  dots2 <- dots[seq(1, dimsdots, by = interval),]
  points(dots2[,ploton.x], dots2[,ploton.y], pch = 19, col = clr)
  return(mean(as.numeric(dots$value), na.rm = TRUE))
}

plot.anim.background <- function(run.name, surrogate.name, ploton.x, ploton.y, n, dt, background = FALSE, slice = NA, example = TRUE){
  require(ggplot2)
  require(viridis)
  require(R.matlab)
  
  if(surrogate.name == "COT" || surrogate.name == "Q"){
    axis.labels <- matrix(c("Wo","CR","Freq"),nrow=3,dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(0.1, 10, 0.4, 1.0, 0.5, 2.0),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  } else if (surrogate.name == "clcd" || surrogate.name == "clvz" || surrogate.name == "clcdclvz"){
    axis.labels <- matrix(c("AR", "Camber", "Re"),nrow=3, dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(3, 12,0, 0.2, 10000, 200000),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  }
  
  if(file.exists(paste("./results/", run.name, "/dots_0.csv", sep = ""))){
    file.pathname <- paste("./results/", run.name, "/", sep = "")
  } else {
    file.pathname <- paste("../results/", run.name, "/", sep = "")
  }
  
  if(background == TRUE){
    if (ploton.x == "x" && ploton.y == "y") {
      ploton.slice="z"
    }else if(ploton.x == "x" && ploton.y == "z") {
      ploton.slice="y"
    }else if(ploton.x == "y" && ploton.y == "z"){
      ploton.slice="x"
    }else {
      stop("Unknown ploton combination.")
    }
    input <- load.matdata(surrogate.name, "input", example, FALSE)
    surrogate <- load.matdata(surrogate.name, "surrogate", example, FALSE)
    data <- data.frame("x"=input[,1], "y"=input[,2], "z" = input[,3], 
                                "surrogate" = surrogate)
    background.data <- data[data[ploton.slice] == slice,]
    p1 <- ggplot(background.data, aes_string(x=ploton.x, y=ploton.y, fill="surrogate")) + 
      geom_tile() + theme_minimal() +
      xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
      xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
      scale_fill_viridis(option = "C", name = surrogate.name)
  }
  
  dir.create(paste(file.pathname, "animplot", ploton.x, ploton.y,"/", sep = ""), showWarnings = FALSE)
  
  for(u in seq(0, n, by = dt)){
    
    if(u == 0){
      dots_0 <- read.table(paste(file.pathname, "dots_0.csv", sep = ""), 
                           sep = " ", header = TRUE)
        if(background == TRUE){
          p2 <- p1+ geom_point(data=dots_0, mapping=aes_string(x = ploton.x, y = ploton.y),
                               pch=21, fill="white",color="black") 
        } else{
          p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y)) + 
            geom_point() + theme_minimal() + 
            xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
            xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ])
        }
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots0.png", sep = ""), p2)
    } else if(u == 1*dt) {
      dots_0 <- read.table(paste(file.pathname, "dots_0.csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_1 <- read.table(paste(file.pathname, "dots_", u, ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      if(background == TRUE){
        p2 <- p1+ geom_point(data=dots_0, mapping=aes_string(x = ploton.x, y = ploton.y),
                             pch=21, fill="gray60",color="gray60") +
                  geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y), 
                             pch=21, fill="white", color="black")
      } else {
        p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y)) + 
           geom_point(col = "gray60", alpha = 1) + theme_minimal() + 
           xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
           xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
           geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y), alpha = 1)
      }
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots", u, ".png", sep = ""), p2)
    } else {
      dots_0 <- read.table(paste(file.pathname, "dots_", (u - 2*dt), ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_1 <- read.table(paste(file.pathname, "dots_", (u - 1*dt), ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_2 <- read.table(paste(file.pathname, "dots_", u, ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      if(background == TRUE){
        p2 <- p1 + geom_point(data=dots_0, mapping=aes_string(x = ploton.x, y = ploton.y),
                              pch=21, fill="gray60",color="gray60", alpha=0.5) +
                   geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y), 
                              pch=21, fill="gray60", color="gray60") +
                   geom_point(data = dots_2, aes_string(x = ploton.x, y = ploton.y), 
                              pch=21, fill="white", color="black")
      } else {
        p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y)) + 
          geom_point(col = "gray60", alpha = 0.5) + theme_minimal() + 
          xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
          xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
          geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y),
                     col = "gray60", alpha = 0.5) +
          geom_point(data = dots_2, aes_string(x = ploton.x, y = ploton.y), alpha = 1)
      }
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots", u, ".png", sep = ""), p2)
    }
    
  }
}

plot.anim <- function(run.name, surrogate.name, ploton.x, ploton.y, n, dt){
  require(ggplot2)
  require(viridis)
  require(R.matlab)
  
  if(surrogate.name == "COT" || surrogate.name == "Q"){
    axis.labels <- matrix(c("Wo","CR","Freq"),nrow=3,dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(0.1, 10, 0.4, 1.0, 0.5, 2.0),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  } else if (surrogate.name == "clcd" || surrogate.name == "clvz" || surrogate.name == "clcdclvz"){
    axis.labels <- matrix(c("AR", "Camber", "Re"),nrow=3, dimnames=list(cols=c("x","y","z")))
    axis.range <- matrix(c(3, 12,0, 0.2, 10000, 200000),nrow=3, byrow=TRUE, 
                         dimnames = list(rows=c("x","y","z"),cols=c("low","high")))
  }
  
  if(file.exists(paste("./results/", run.name, "/dots_0.csv", sep = ""))){
    file.pathname <- paste("./results/", run.name, "/", sep = "")
  } else {
    file.pathname <- paste("../results/", run.name, "/", sep = "")
  }
  
  surrogate <- load.matdata(surrogate.name, "surrogate", TRUE, FALSE)
  range.surrogate <- range(surrogate)
  dir.create(paste(file.pathname, "animplot", ploton.x, ploton.y,"/", sep = ""), showWarnings = FALSE)
  
  for(u in seq(0, n, by = dt)){
    
    if(u == 0){
      dots_0 <- read.table(paste(file.pathname, "dots_0.csv", sep = ""), 
                           sep = " ", header = TRUE)
      p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y, fill = "value")) + 
          geom_point(pch=21, size=2, color="black") + theme_minimal() + 
          xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
          xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
          scale_fill_viridis(alpha = 1, option = "C", limits = range.surrogate, name = surrogate.name)
      
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots0.png", sep = ""), p2)
    } else if(u == 1*dt) {
      dots_0 <- read.table(paste(file.pathname, "dots_0.csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_1 <- read.table(paste(file.pathname, "dots_", u, ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      
        p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y, fill = "value")) + 
          geom_point(pch=21, size=2, color="black", alpha = 0.05) + theme_minimal() + 
          xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
          xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
          geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y, fill="value"), 
                     pch=21, size=2, color="black", alpha = 1) +
          scale_fill_viridis(alpha = 1, option = "C", limits = range.surrogate, name = surrogate.name)
      
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots", u, ".png", sep = ""), p2)
    } else {
      dots_0 <- read.table(paste(file.pathname, "dots_", (u - 2*dt), ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_1 <- read.table(paste(file.pathname, "dots_", (u - 1*dt), ".csv", sep = ""), 
                           sep = " ", header = TRUE)
      dots_2 <- read.table(paste(file.pathname, "dots_", u, ".csv", sep = ""), 
                           sep = " ", header = TRUE)
        p2 <- ggplot(dots_0, aes_string(x = ploton.x, y = ploton.y, fill = "value")) + 
          geom_point(col = "gray60", alpha = 0.5) + theme_minimal() + 
          xlim(axis.range[ploton.x, ]) + ylim(axis.range[ploton.y, ]) +
          xlab(axis.labels[ploton.x, ]) + ylab(axis.labels[ploton.y, ]) +
          geom_point(data = dots_1, aes_string(x = ploton.x, y = ploton.y, fill = "value"),
                     pch=21, size=2, color="gray60", alpha = 0.5) +
          geom_point(data = dots_2, aes_string(x = ploton.x, y = ploton.y, fill = "value"), 
                     pch=21, size=2, color="black", alpha = 1) +
          scale_fill_viridis(alpha = 1, option = "C", limits = range.surrogate, name = surrogate.name)
      
      ggsave(filename = paste(file.pathname, "animplot", ploton.x, ploton.y, 
                              "/dots", u, ".png", sep = ""), p2)
    }
    
  }
}
