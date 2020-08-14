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
y <- "IsArrDelayed"
xForeheadSlap <- setdiff(colnames(data),y)

xAll <- setdiff(colnames(data), c(
  "ArrDelay", "DepDelay",
  "CarrierDelay", "WeatherDelay",
  "LateAircraftDelay", "IsDepDelayed",
  "IsArrDelayed", "ActualElapsedTime"
))

xLilely <- c("Month", "DayOfWeek", "UniqueCarrier",
             "Origin", "Dest", "Distance", "Cancelled", "Diverted")


m_def = h2o.glm(xAll, y, train,
                validation_frame = valid,
                family = "binomial")
  


h2o.performance(m_def, valid=TRUE)

g <- h2o.grid("glm",
              search_criteria = list(
                strategy = "RandomDiscrete", #Cartesian
                max_models = 8,
                max_runtime_secs = 30
              ),
              hyper_params = list(
                alpha = seq(0,0.99,0.01)
              ),
              grid_id = "random8",
              x = xAll,
              y = y,
              training_frame = train,
              validation_frame= valid,
              family = "binomial",
              lambda_search = TRUE)
g


              

  
  

