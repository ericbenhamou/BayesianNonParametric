require(h2o)

cl <- h2o.init(
  max_mem_size = "4G",
  nthreads = 2)


## data setup
setwd('C:/Users/eric.benhamou/Documents/R/Projects/BNP/code')
digits.train <- read.csv("train.csv")
digits.train$label <- factor(digits.train$label, levels = 0:9)

h2odigits <- as.h2o(
  digits.train,
  destination_frame = "h2odigits")

i <- 1:32000
h2odigits.train <- h2odigits[i, ]
itest <- 32001:42000
h2odigits.test <- h2odigits[itest, ]
xnames <- colnames(h2odigits.train)[-1]
 

system.time(ex1 <- h2o.deeplearning(
  x = xnames,
  y = "label",
  training_frame= h2odigits.train,
  validation_frame = h2odigits.test,
  activation = "RectifierWithDropout",
  hidden = c(100),
  epochs = 10,
  adaptive_rate = FALSE,
  rate = .001,
  input_dropout_ratio = 0,
  hidden_dropout_ratios = c(.2)
))
system.time(ex2 <- h2o.deeplearning(
  x = xnames,
  y = "label",
  training_frame= h2odigits.train,
  validation_frame = h2odigits.test,
  activation = "RectifierWithDropout",
  hidden = c(100),
  epochs = 10,
  adaptive_rate = FALSE,
  rate = .01,
  input_dropout_ratio = 0,
  hidden_dropout_ratios = c(.2)
))

ex1

(ex2)
