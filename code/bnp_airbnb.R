#clean environment
rm(list=ls())
setwd(dir = "C:/Users/eric.benhamou/Documents/R/Projects/BNP/code")
library(ggplot2)

age_gender = read.csv( "Airbnb/age_gender_bkts.csv")
countries = read.csv( "Airbnb/countries.csv")
train_users  = read.csv( "Airbnb/train_users_2.csv")
#test_users  = read.csv( "Airbnb/test_users.csv")
#session = read.csv( "Airbnb/sessions.csv")

# ggplot(train_users, aes(x=gender)) + 
#   stat_count(fill="salmon")
(n=length(train_users$gender))
barplot(sort(prop.table(table(train_users$gender)), decreasing=T), col="salmon")
destination = train_users$country_destination

dest_male = table(destination[ gender == "MALE"])
dest_female = table(destination[ gender == "FEMALE"])
dest = data.frame(cbind(dest_male,dest_female))
(dest = dest[order(dest$dest_female, decreasing = T),])
barplot(t(dest), col=c("orange","turquoise"),
  beside = T, legend=c("male", "female"), las = 2)

#check any column and print column with na
for( column in colnames(train_users)){
  if( anyNA(train_users[column] )){
      print( column)
  }
}

#check any column and print column with na
for( column in colnames(session)){
  if( anyNA(session[column] )){
    print( column)
  }
}

#delete session sec
session$secs_elapsed = NULL

#load h2o
library(h2o)
h2o.init(nthreads=-1, max_mem_size="2G")
h2o.removeAll() ## clean slate - just in case the cluster was already running
train_users.hex = as.h2o(train_users[1:10000,])


## First, we will create three splits for train/test/valid independent data sets.
## We will train a data set on one set and use the others to test the validity
## of model by ensuring that it can predict accurately on data the model has not
## been shown.
## The second set will be used for validation most of the time. The third set will
## be withheld until the end, to ensure that our validation accuracy is consistent
## with data we have never seen during the iterative process. 
splits = h2o.splitFrame(
  train_users.hex,           ##  splitting the H2O frame we read above
  c(0.7,0.2),   ##  create splits of 60% and 20%; 
  ##  H2O will create one more split of 1-(sum of these parameters)
  ##  so we will get 0.7 / 0.2 / 1 - (0.7+0.2) = 0.7/0.2/0.1
  seed=1234)    

train = h2o.assign(splits[[1]], "train.hex")   
## assign the first result the R variable train
## and the H2O name train.hex
test <- h2o.assign(splits[[2]], "test.hex")     ## R test, H2O test.hex
valid = h2o.assign(splits[[3]], "valid.hex")   ## R valid, H2O valid.hex

(dim(train))
(dim(valid))


## run our first predictive model
rf1 <- h2o.randomForest(         ## h2o.randomForest function
  training_frame = train,        ## the H2O frame for training
  validation_frame = valid,      ## the H2O frame for validation (not required)
  x=1:15,                        ## the predictor columns, by column index
  y=16,                          ## the target index (what we are predicting)
  model_id = "rf_country",       ## name the model in H2O
                                 ##   not required, but helps use Flow
  ntrees = 70,                   ## use a maximum of 200 trees to create the
                                 ##  random forest model. The default is 50.
                                 ##  I have increased it because I will let 
                                 ##  the early stopping criteria decide when
                                 ##  the random forest is sufficiently accurate
  stopping_rounds = 2,           ## Stop fitting new trees when the 2-tree
                                 ##  average is within 0.001 (default) of 
                                 ##  the prior two 2-tree averages.
                                 ##  Can be thought of as a convergence setting
  score_each_iteration = T,      ## Predict against training and validation for
                                 ##  each tree. Default will skip several.
  seed = 1000000)                ## Set the random seed so that this can be
                                 ##  reproduced.


###############################################################################
summary(rf1)                     ## View information about the model.
## Keys to look for are validation performance
##  and variable importance

rf1@model$validation_metrics     ## A more direct way to access the validation 
##  metrics. Performance metrics depend on 
##  the type of model being built. With a
##  multinomial classification, we will primarily
##  look at the confusion matrix, and overall
##  accuracy via hit_ratio @ k=1.
h2o.hit_ratio_table(rf1,valid = T)[1,2]

#plot variable importance
h2o.varimp_plot(rf1)

#test on test
(perf = h2o.performance(rf1,test))

#---------------------------
#deep learning
#---------------------------
splits2 = h2o.splitFrame(
  train_users.hex,           ##  splitting the H2O frame we read above
  c(0.6,0.2),   ##  create splits of 60% and 20%; 
  ##  H2O will create one more split of 1-(sum of these parameters)
  ##  so we will get 0.7 / 0.2 / 1 - (0.7+0.2) = 0.7/0.2/0.1
  seed=1234)    

train2 = h2o.assign(splits2[[1]], "train.hex")   
## assign the first result the R variable train
## and the H2O name train.hex
valid2 = h2o.assign(splits2[[2]], "valid.hex")   ## R valid, H2O valid.hex
(dim(train2))
(dim(valid2))


system.time(dl1 <- h2o.deeplearning(
  x = 1:15,
  y = 16,
  training_frame= train2,
  validation_frame = valid2,
  activation = "RectifierWithDropout",
  hidden = c(50),
  epochs = 20,
  loss = "CrossEntropy",
  adaptive_rate = FALSE,
  rate = .001,
  input_dropout_ratio = 0,
  hidden_dropout_ratios = c(.2)
))


###############################################################################
summary(dl1)
dl1@model$validation_metrics     ## A more direct way to access the validation 
h2o.hit_ratio_table(dl1,valid = T)[1,2]

