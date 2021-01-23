# Testing the DotWalkR simulation

#Adding required libraries
library(testthat)
library(R.matlab)
library(parallel)
library(doParallel)
library(data.table)
library(foreach)

setwd("..")
source("./src/functions/walkR_functions.R")

#registerDoParallel(cores = 2)

x <- 100
test.dataset <- matrix(data=c(seq(0, 1, length=x),
                              seq(3, 8, length=x),
                              seq(1e-2, 1e-4, length=x)), 
                       ncol = 3)
test.valueset <- matrix(rep(0, length = x))
test.valueset[39] <- 1
test.valueset[21] <- 1
test.point1 <- matrix(c(0.3838384, 4.9191919, 0.0062000), ncol = 3)

#### getMeanValue() Tests ####

context("Test getMeanValue()")

test_that("Data types", {
          expect_error(getMeanValue(test.dataset, test.valueset, c(0.3838384, 4.9191919, 0.0062000), 1))
          expect_error(getMeanValue(as.vector(test.dataset), test.valueset, test.point1, 1))
          expect_error(getMeanValue(test.dataset, as.data.frame(test.valueset), test.point1, 1))
          })

test_that("Correct Points", {
          expect_equal(getMeanValue(test.dataset, test.valueset, test.point1, 1), 1)
          })

#### scale.dots() Tests ####

context("Test scale.dots()")

scaled.testdataset <- scale.dots(test.dataset, 
                                 range(test.dataset[, 1]), 
                                 range(test.dataset[, 2]), 
                                 range(test.dataset[, 3]))

test_that("Data types",{
          expect_error(dots(as.data.frame(test.dataset), range(test.dataset[,1]), 
                            range(test.dataset[,2]),
                            range(test.dataset[,3])))
          expect_error(dots(as.data.frame(test.dataset), c(3,4,1,5), 
                             range(test.dataset[,2]),
                             range(test.dataset[,3])))
          expect_error(dots(as.data.frame(test.dataset), range(test.dataset[,1]), 
                            as.matrix(range(test.dataset[,2])),
                            range(test.dataset[,3])))
          expect_error(dots(as.data.frame(test.dataset), range(test.dataset[,1]), 
                            range(test.dataset[,2]),
                            "1"))
})

test_that("Correct scaling",{
          expect_equal(range(scaled.testdataset[,1]), c(0,1))
          expect_equal(range(scaled.testdataset[,2]), c(0,1))
          expect_equal(range(scaled.testdataset[,3]), c(0,1))
})

#### Test herd.dots() ####

context("Test herd.dots()")

herded.dots <- matrix(data = runif(300, min=0, max = 13), ncol = 3)
colnames(herded.dots) <- c("x","y","z")
herded.dots<-herd.dots(herded.dots, "x", c(0,1))
herded.dots<-herd.dots(herded.dots, "y", c(0,1))
herded.dots<-herd.dots(herded.dots, "z", c(0,1))

test_that("Herding-dots",{
          expect_false(max(herded.dots[,1]) > 1)
          expect_false(max(herded.dots[,2]) > 1)
          expect_false(max(herded.dots[,3]) > 1)
          expect_false(max(herded.dots[,1]) < 0)
          expect_false(max(herded.dots[,2]) < 0)
          expect_false(max(herded.dots[,3]) < 0)
})


#### Tests find.betas() ####

context("Test find.betas()")

gradX <- load.matdata("constx", "gradx", test = TRUE)
gradY <- load.matdata("constx", "grady", test = TRUE)
gradZ <- load.matdata("constx", "gradz", test = TRUE)

beta <- find.betas(test.point1, gradX, gradY, gradZ, test.dataset, scaled.testdataset, 3, 0.01)

test_that("Test constant x gradient",{
        expect_equal(beta[1], 0.18)
        expect_equal(beta[2], 0)
        expect_equal(beta[3], 0)
})

rm(gradX,gradY,gradZ, beta)
gradX <- load.matdata("consty", "gradx", test = TRUE)
gradY <- load.matdata("consty", "grady", test = TRUE)
gradZ <- load.matdata("consty", "gradz", test = TRUE)

beta <- find.betas(test.point1, gradX, gradY, gradZ, test.dataset, scaled.testdataset, 3, 0.01)

test_that("Test constant y gradient",{
  expect_equal(beta[1], 0)
  expect_equal(beta[2], 0.004)
  expect_equal(beta[3], 0)
})

rm(gradX,gradY,gradZ, beta)
gradX <- load.matdata("constz", "gradx", test = TRUE)
gradY <- load.matdata("constz", "grady", test = TRUE)
gradZ <- load.matdata("constz", "gradz", test = TRUE)

beta <- find.betas(test.point1, gradX, gradY, gradZ, test.dataset, scaled.testdataset, 3, 0.01)

test_that("Test constant z gradient",{
  expect_equal(beta[1], 0)
  expect_equal(beta[2], 0)
  expect_equal(beta[3], 3800)
})

#### Testing main function! ####

context("Testing dotwalkR")

assign("test", as.logical("TRUE"),envir = .GlobalEnv)

assign("parameter.filename", "./tests/testdata/parameters-testconstx", envir = .GlobalEnv)
source("./src/dotwalkr.R")

assign("parameter.filename", "./tests/testdata/parameters-testconstz", envir = .GlobalEnv)
source("./src/dotwalkr.R")

assign("parameter.filename", "./tests/testdata/parameters-testconsty", envir = .GlobalEnv)
source("./src/dotwalkr.R")

dotsx <- read.table("./tests/results/_constx/dots_1.csv", header= TRUE)
dotsx <- as.data.frame(dotsx)

dotsy <- read.table("./tests/results/_consty/dots_1.csv", header= TRUE)
dotsy <- as.data.frame(dotsy)

dotsz <- read.table("./tests/results/_constz/dots_1.csv", header= TRUE)
dotsz <- as.data.frame(dotsz)


test_that("Test constant x gradient climb",{
  expect_true(all(dotsx$x > 5.5))
  expect_true(all(dotsx$y == 0.1))
  expect_true(all(dotsx$z == 105000))
})


test_that("Test constant y gradient climb",{
  expect_true(all(dotsy$x == 5.5))
  expect_true(all(dotsy$y > 0.1))
  expect_true(all(dotsy$z == 105000))
})


test_that("Test constant z gradient climb",{
  expect_true(all(dotsz$x == 5.5))
  expect_true(all(dotsz$y == 0.1))
  expect_true(all(dotsz$z > 105000))
})

