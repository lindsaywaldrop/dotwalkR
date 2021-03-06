###############################################################
##### DotWalkR Main Program ####
###############################################################

#### Initialize program ####
source("./src/init_dotwalk.R")

#### Initialize dotwalkr variables ####
time.now <- 0 
id <- matrix(c(1, 1, 1), ncol = 1)
newdots <- dots

#### Saving initial dot data ####
if (t.save.interval != 0) {
  scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                            range(input.real[, 2]), 
                            range(input.real[, 3]))
  
  dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
  save.dots(folder.name, dots, time.now)
}

#### Main program loop #### 
print(paste("Simulation time:", time.now, "generations"))

while (time.now < end.time){ # Begin Main loop
  
  beta <- find.betas(dots, gradX, gradY, gradZ, input.real, input.scaled, dN, delta.t)
  deltaf <- matrix(data = NA,nrow = n, ncol = 3)
  for (j in 1:n) {
    M <- generaterandM(3) # Calculates initial M matrix of random numbers 
    deltaf[j, ] <- t((randscale*(1 - (A %*% id))*M*(1/k)*delta.t)) + k*walktowards*beta[j, ]*delta.t
    newdots[j, 1:3] <- deltaf[j, ] + dots[j, 1:3]
  }
  
  newdots <- herd.dots(newdots, "x", range(input.real[ ,1]))
  newdots <- herd.dots(newdots, "y", range(input.real[ ,2]))
  newdots <- herd.dots(newdots, "z", range(input.real[ ,3]))
  
  dots <- newdots
  time.now <- time.now + 1
  
  if (t.save.interval != 0 && time.now %% t.save.interval == 0) {
    print(paste("Simulation time:", time.now, "generations"))
    scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                              range(input.real[, 2]), 
                              range(input.real[, 3]))
    
    dots[ ,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
    save.dots(folder.name, dots, time.now)}
  
} # End main loop

#### Saving final dot data ####
if (t.save.interval != 0) {
  scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                            range(input.real[, 2]), 
                            range(input.real[, 3]))
  
  dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
  save.dots(folder.name, dots, end.time)
}
