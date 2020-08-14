library(h2o)
h2o.init()

data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

summary(data)

# data[, "xxx"] <- as.factor( data[, "xxx"])
# data[, "xxx"] <- as.numeric( data[, "xxx"])

#Column stats
 
mean(data[,"AirTime"])
mean(data[, "AirTime"], na.rm = TRUE)
h2o.mean(data[,"AirTime"], na.rm=TRUE)

range(data [, "AirTime"], na.rm=TRUE)

h2o.hist(data[,"AirTime"])

mean(data[,c("ArrDelay", "DepDelay")], na.rm=TRUE)

h2o.any(data[,"ArrDelay"] > 360)
h2o.all(data[, "ArrDelay"] < 480)
#... but it has no na.rm argument, so we need:
h2o.all(h2o.na_omit(data[,"ArrDelay"])<480)

h2o.cumsum(data[, "ArrDelay"], axis=0)

h2o.cor(data[,"ArrDelay"], data[,"DepDelay"], na.rm=T)

