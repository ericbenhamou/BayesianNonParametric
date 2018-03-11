#clean environment
rm(list=ls())
setwd(dir = "C:/Users/eric.benhamou/Documents/R/Projects/BNP/")
library(ggplot2)


age_gender = read.csv( "Airbnb/age_gender_bkts.csv")
countries = read.csv( "Airbnb/countries.csv")
train_users  = read.csv( "Airbnb/train_users_2.csv")

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

account = train_users$date_account_created
cutoff  = as.POSIXct("2014-01-01");
dest_bf_2014 = table(destination[  account<= cutoff ])
dest_af_2014 = table(destination[  account>  cutoff ])
dest = data.frame(cbind(dest_bf_2014,dest_af_2014))
(dest = dest[order(dest$dest_af_2014, decreasing = T),])
barplot(t(dest), col=c("turquoise","green"),
        beside = T, legend=c("before 2014", "after 2014"), las = 2)


require(mxnet)
net <- mx.symbol.Variable("data")
net <- mx.symbol.FullyConnected(data=net, name="fc1", num_hidden=128)
net <- mx.symbol.Activation(data=net, name="relu1", act_type="relu")
net <- mx.symbol.FullyConnected(data=net, name="fc2", num_hidden=64)
net <- mx.symbol.Softmax(data=net, name="out")
class(net)
