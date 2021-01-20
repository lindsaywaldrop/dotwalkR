source("./src/init_dotwalk.R")

t <- 0 
loopn <- 0
id <- matrix(c(1,1,1),ncol=1)
newdots <- dots

if (t.save.interval != 0) {
  scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                            range(input.real[, 2]), 
                            range(input.real[, 3]))
  
  dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
  save.dots(dots, t)
}

print(paste("Simulation time:", round(t, digits=2),"s"))

while (t < end.time){
  
  beta <- find.betas(dots, gradX, gradY, gradZ, input.real, input.scaled, delta.t)
  deltaf <- matrix(data = NA,nrow = n, ncol = 3)
  for (j in 1:n) {
    M <- generaterandM(3) # Calculates initial M matrix of random numbers 
    deltaf[j,] <- t((randscale*(1-(A %*% id))*M*delta.t)) + k*walktowards*beta[j,]*delta.t
    newdots[j,1:3] <- deltaf[j,] + dots[j,1:3]
  }
  
  newdots <- herd.dots(newdots,"x",range(input.real[,1]))
  newdots <- herd.dots(newdots,"y",range(input.real[,2]))
  newdots <- herd.dots(newdots,"z",range(input.real[,3]))
  
  dots <- newdots
  t <- t + delta.t
  loopn <- loopn + 1
  
  if (t.save.interval != 0 && loopn %% t.save.interval == 0) {
    print(paste("Simulation time:", round(t, digits=2),"s"))
    scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                              range(input.real[, 2]), 
                              range(input.real[, 3]))
    
    dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
    save.dots(dots, round(t, digits=2))}
  
}

if (t.save.interval != 0) {
  scaled.dots <- scale.dots(dots, range(input.real[, 1]), 
                            range(input.real[, 2]), 
                            range(input.real[, 3]))
  
  dots[,4] <- getMeanValue(input.scaled, surrogate, scaled.dots, 3)
  save.dots(dots, end.time)
}
