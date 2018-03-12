## uncomment to install the checkpoint package
## install.packages("checkpoint")
library(checkpoint)

checkpoint("2016-02-20", R.version = "3.2.3")

## Chapter 1 ##

## Tools
library(RCurl)
library(jsonlite)
library(caret)
library(e1071)

## basic stats packages
library(statmod)
library(MASS)

## neural networks
library(nnet)
library(neuralnet)
library(RSNNS)

## deep learning
library(deepnet)
library(darch)
library(h2o)


## libray for training
library(parallel)
library(foreach)
library(doSNOW)

## library glmnet
library(glmnet)

## library data.table
library(data.table)

##  library for grid
library(gridExtra)
library(mgcv)