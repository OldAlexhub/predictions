# Load required libraries
library(dplyr)
library(mongolite)
library(prophet)
library(lubridate)
library(plumber)
library(dotenv)

Url <- Sys.getenv('Url')

# MongoDB connection strings
mongo_batteries <- mongo(
  collection = 'batteries',
  url = Url
)

mongo_forecasts <- mongo(
  collection = 'rangeforecasts',
  url = Url
)

# Define the Plumber API
# Create a plumber router
pr <- plumber$new()

#* @param userId The ID of the user to process
#* @get /processData
pr$handle("GET", "/processData", function(userId) {
  
  # Check if the data for this userId has already been processed
  existing_predictions <- mongo_forecasts$find(query = paste0('{"userId": "', userId, '"}'))
  
  if (nrow(existing_predictions) > 0) {
    return(list(message = paste("UserId", userId, "has already been processed. Skipping ML analysis.")))
  }
  
  # Fetch data for the userId
  data <- mongo_batteries$find(query = paste0('{"userId": "', userId, '"}'))
  
  if (nrow(data) == 0) {
    return(list(message = paste("No data found for UserId", userId)))
  }
  
  # Process and clean the data
  data <- data %>%
    filter(userId == userId)
  
  # Handle date conversions
  data$date_parsed <- ifelse(nchar(as.character(data$date)) > 10,
                             format(as_datetime(as.numeric(data$date)), "%Y-%m-%d"),
                             format(ymd(data$date), "%Y-%m-%d"))
  
  # Clean up the dataset
  data <- data %>%
    select(-date) %>%
    rename(date = date_parsed)
  
  data <- na.omit(data)
  data$date <- as.Date(data$date, format = '%Y-%m-%d')
  
  # Prepare data for Prophet
  prophetData <- data %>%
    group_by(ds = date) %>%
    summarise(y = round(current_miles))
  
  # Fit Prophet model
  prophetModel <- prophet(prophetData)
  
  # Generate future data for the next 30 days
  future <- make_future_dataframe(prophetModel, periods = 30, freq = 'day')
  forecast <- predict(prophetModel, future)
  
  # Create prediction dataframe
  predictions <- data.frame(
    userId = userId,
    date = forecast$ds,
    prediction = forecast$yhat
  )
  
  # Insert predictions into MongoDB
  mongo_forecasts$insert(predictions)
  
  return(list(message = paste("UserId", userId, "has been processed successfully.")))
})

# Start the API
pr$run(port = 8000)
