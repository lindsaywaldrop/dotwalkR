#### Install script ####

#### Required Packages ####
message("Testing for required packages, installing if not found.")
message(" ")
packages <- c("testthat", "R.matlab","data.table", "parallel", "doParallel", 
              "foreach", "viridis")

package.check <- lapply(
  packages,
  FUN <- function(x) {
    if (!require(x, character.only = TRUE)) {
      message(paste("Installing Package ", x," now."))
      install.packages(x, dependencies = TRUE, repos='http://cran.us.r-project.org')
      library(x, character.only = TRUE)
    } else { 
      message(paste("Package ", x," found."))
    }
  }
)
message("Done with required packages!")
message(" ")

#### Test Dotwalkr ####
library(testthat)

message("Running tests now... ")

test_dir("tests")

message("Testing complete. If passed, you are ready to use the DotwalkR.")

