cran <- getOption("repos")
cran["dmlc"] <- "https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/R/CRAN/"
options(repos = cran)
install.packages("mxnet")

# I add to install another verion of diagrammeR
# because otherwise, I had a bug
# require(devtools)
# install_version("DiagrammeR", version = "0.9.0", repos = "http://cran.us.r-project.org")
# require(DiagrammeR)

# test mxnet
library(mxnet)
a <- mx.nd.ones(c(2,3), ctx = mx.cpu())
b <- a * 2 + 1
b

