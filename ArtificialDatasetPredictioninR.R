library(tidyverse)
library(h2o)
h2o.init()

set.seed(456)

N <- 2000

d <- data.frame(id = 1:N)

d$bloodType <- bloodType[
   (d$id %% length(bloodType))
   +1
]

bloodType <- c('a','a','a','o', 'o', 'o', 'ab', 'b') 
d$bloodType <- as.factor(bloodType[(d$id %% length(bloodType))+1])

d$age = runif(N, min=5, max=75)

v = round(rnorm(N, mean=6, sd=2))
v = pmax(v, 0)
v = pmin(v, 9)
table(v)
d$healthyEating = v

v = round(rnorm(N, mean=5, sd=2))
v = v + ifelse(d$age>30, -3, 0)
v = pmax(v, 0)
v = pmin(v, 9)
table(v)
d$activeLifestyle = v

v = 30000 + ((d$age *3)^2)
v = v - (d$healthyEating * 1000)
v = v + (d$activeLifestyle * 100)
v = v + runif(N,0,3000)

d$income = round(v, -2)

as.h2o(d, destination_frame = 'ppl_income')

summary('ppl_income')

people <- h2o.getFrame('ppl_income')
parts <- h2o.splitFrame(people, 
                        c(0.7, 0.15),
                        destination_frames = c('people_train', 'people_valid', 'people_test'),
                        seed = 456
                        )
  
  
sapply(parts, nrow)
  
train <- parts[[1]]
valid <- parts[[2]]
test <- parts[[3]]

train <- h2o.getFrame("people_train")
valid <- h2o.getFrame("people_valid")
test <- h2o.getFrame("people_test")

y <- "income"
x <- setdiff(names(train), c("id", y))

mGBM <- h2o.gbm(x, y, train, model_id = "default_gbm",
                validation_frame = valid)

h2o.performance(mGBM, train = TRUE)
h2o.performance(mGBM, valid = TRUE)
h2o.performance(mGBM, test)

mRF <- h2o.randomForest(x, y, train, model_id = "default_rf",
                        validation_frame = valid)

h2o.performance(mRF, train = TRUE)
h2o.performance(mRF, valid = TRUE)
h2o.performance(mRF, test)

mGBM2 <- h2o.gbm(x, y, train, model_id = "overfit_gbm",
                validation_frame = valid,
                ntrees = 500,
                max_depth = 15)

h2o.performance(mGBM2, train = TRUE)
h2o.performance(mGBM2, valid = TRUE)
h2o.performance(mGBM2, test)

mRF2 <- h2o.randomForest(x, y, train, model_id = "overfit_rf",
                        validation_frame = valid,
                        ntrees = 1000,
                        max_depth = 30)

h2o.performance(mRF2, train = TRUE)
h2o.performance(mRF2, valid = TRUE)
h2o.performance(mRF2, test)

h2o.shutdown()
h2o.shutdown(prompt = FALSE)



