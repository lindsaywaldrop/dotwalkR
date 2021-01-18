
# These are the 3D coordinates of the surrogate plot.
input.data <- readMat("./test/exampledata/input_resampled.mat")
# input.data[["input"]] is a 9261x3 matrix: [,1] is x, [,2] is y, and [,3] is z.
input.real<-input.data[["input"]]
input.scaled<-scale.dots(input.real,range(input.real[,1]), range(input.real[,2]), range(input.real[,3]))
rm(input.data)
# These are the values of the scalar surrogate plot.
fmat.data <- readMat("./test/exampledata/clcd_resampled_long.mat")
# fmat.data[["fmat"]] is a 9261x1 vector which are the scalar values, each row corresponds to the 3D
# coordinates in input.data[["input"]].
surrogate<-fmat.data[["fmat"]]
rm(fmat.data)

fmat.data <- readMat("./test/exampledata/clcd_resampled_gradX_long.mat")
gradX<-fmat.data[["gradx"]]
rm(fmat.data)
fmat.data <- readMat("./test/exampledata/clcd_resampled_gradY_long.mat")
gradY<-fmat.data[["grady"]]
rm(fmat.data)
fmat.data <- readMat("./test/exampledata/clcd_resampled_gradZ_long.mat")
gradZ<-fmat.data[["gradz"]]
rm(fmat.data)

  