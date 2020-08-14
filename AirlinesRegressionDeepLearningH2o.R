library(h2o)
h2o.init()
h2o.init(nthreads = -1)

airlines_path <- "https://s3.amazonaws.com/h2o-airlines-unpacked/allyears2k.csv"
data <- h2o.importFile(path = airlines_path)

#data <- h2o.importFile("http://h2o-public-test-data.s3.amazonaws.com/smalldata/airlines/allyears2k_headers.zip")

nrow(data)

summary(data)

parts <- h2o.splitFrame(data, c(0.8,0.1), seed = 690)

train <- parts[(1)]
valid <- parts[(2)]
test <- parts[(3)]

h2o.describe(data)
y <- "ArrDelayed"


xWithDep <- setdiff(colnames(data), c(
  "ArrDelay", "IsArrDelayed",
   "ActualElapsedTime", "TainNum", "ArrTime"
))

xLilely <- c("Month", "DayOfWeek", "UniqueCarrier",
             "Origin", "Dest", "Distance", "Cancelled", "Diverted")


#deep learning model

m_DLR_def = h2o.deeplearning(xWithDep, y, train,
                validation_frame = valid,
                model_id = "DLR_def",
                variable_importances = TRUE)
  


h2o.performance(mDL_def, valid=TRUE)

plot(mDL_def)

mDL_200_epochs <- h2o.deeplearning(xAll, y, train,
                           validation_frame = valid,
                           epochs = 200,
                           stopping_rounds = 5,
                           stopping_tolerance = 0,
                           stopping_metric = "logloss"
                           )


h2o.performance(mDL_200_epochs, valid=TRUE)

plot(mDL_200_epochs)
h2o.scoreHistory(mDL_200_epochs)

#grid with deep learning
              
gDL <- h2o.grid("deeplearning",
              search_criteria = list(
                strategy = "RandomDiscrete", #Cartesian
                max_models = 4,
                max_runtime_secs = 30
              ),
              hyper_params = list(
                seed = c(77),
                l1 = c(0, 1e-6, 3e-6, 1e-5),
                l2 = c(0, 1e-6, 3e-6, 1e-5),
                input_dropout_ratios = list(
                  c(0,0),
                  c(0.2, 0.2),
                  c(0.4,0.4),
                  c(0.6,0.6),
                ),
              ),
              grid_id = "dl-test",
              x = xAll,
              y = y,
              hidden = c(400, 400),
              epochs = 40,
              training_frame = train,
              validation_frame= valid,
              activation = "RectifierWithDropout",
              lambda_search = TRUE)
gDL

  
  

