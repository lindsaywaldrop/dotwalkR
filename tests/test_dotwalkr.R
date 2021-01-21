# Testing the DotWalkR simulation

#Adding required libraries
library(testthat)
library(R.matlab)
library(doParallel)

source("../src/functions/walkR_functions.R")

registerDoParallel(cores = 1)

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

test.point2 <- matrix(data = c(0), ncol = 3)
