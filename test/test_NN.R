# Test Nearest Neighbor functions
library(R.matlab)

source("./src/functions/NearestNeighbor.R")

# These are the 3D coordinates of the surrogate plot.
input.data <- readMat("./test/exampledata/input_resampled.mat")
# input.data[["input"]] is a 9261x3 matrix: [,1] is x, [,2] is y, and [,3] is z.
input<-input.data[["input"]]

# These are the values of the scalar surrogate plot.
fmat.data <- readMat("./test/exampledata/clcd_resampled_long.mat")

dataset = list(
  #Can of course be imported from a file or defined inline.
  c(2.7810836, 2.550537003, 0),
  c(1.465489372, 2.362125076, 0),
  c(3.396561688, 4.400293529, 0),
  c(1.38807019, 1.850220317, 0),
  c(3.06407232, 3.005305973, 0),
  c(7.627531214, 2.759262235, 1),
  c(5.332441248, 2.088626775, 1),
  c(6.922596716, 1.77106367, 1),
  c(8.675418651,-0.242068655, 1),
  c(7.673756466, 3.508563011, 1)
)

pts <- GetNeighbors(dataset, dataset[[1]], 3)
pts.df <- data.frame(dataset[[pts[[1]]]], dataset[[pts[[2]]]], dataset[[pts[[3]]]])


