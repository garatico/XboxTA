```{r Metrics Preprocessing (EIR)}
eir_df = calculate_engagement_intensity_ratio(frequency_combined_df)
eir_dt = as.data.table(eir_df)  # Convert eir_df to a data.table
eir_dt = eir_dt[order(year, week), .SD, by = data_frame_id]
eir_dt[, cum_engagement := cumsum(engagement_ratio != 0), by = data_frame_id]
eir_dt = eir_dt[cum_engagement > 0]
eir_dt[is.na(total_achievements), total_achievements := 0]
eir_dt[is.na(total_days), total_days := 7]
eir_dt[is.na(engagement_ratio), engagement_ratio := 0]
eir_dt[, cum_engagement := NULL]
eir_dt[, year := as.numeric(year)]
# Label encode the 'month' & 'weekday' variable in eir_dt
eir_dt[, month := as.integer(month)]
eir_dt[, data_frame_id := as.integer(data_frame_id)]
eir_dt[, weekday := ifelse(weekday == "Weekday", 1, 0)]
eir_df = as.data.frame(eir_dt)

```
```{r Model 1 : EIR Train / Test Split}
# Shuffle the unique ids
set.seed(196)
model1_shuffled_ids = sample(unique(eir_df$data_frame_id))
model1_split_point = round(length(model1_shuffled_ids) * 0.75)

# Perform train/test split
model1_train_data = eir_df %>% 
  filter(data_frame_id %in% model1_shuffled_ids[1:model1_split_point])
model1_test_data = eir_df %>% 
  filter(data_frame_id %in% model1_shuffled_ids[(model1_split_point + 1):length(model1_shuffled_ids)])
```

```{r Model 1 : EIR Train}
# Define the features and target variable
model1_features = c("data_frame_id", "year", "week", "month", "weekday", "day_of_year", "total_achievements")  # Updated feature names
model1_target = "engagement_ratio"  # Target variable name remains the same

# Convert the train data to a matrix
model1_train_matrix <- as.matrix(model1_train_data[, model1_features])
model1_test_matrix = as.matrix(model1_test_data[, model1_features])

# Create the DMatrix for training
model1_dtrain = xgb.DMatrix(data = model1_train_matrix, label = model1_train_data[[model1_target]])
model1_dtest = xgb.DMatrix(data = model1_test_matrix, label = model1_test_data[[model1_target]])

# Set the hyperparameters for the XGBoost model
params = list(
  objective = "reg:squarederror",  # Regression task
  max_depth = 8,  # Maximum tree depth
  eta = 0.01,  # Learning rate
  subsample = 0.8,  # Subsample ratio
  colsample_bytree = 0.8  # Feature subsampling ratio
)

# Train the XGBoost model
model1 = xgb.train(params = params, data = model1_dtrain, nrounds = 1000)
```

```{r Model 1 : EIR Predictions}
model1_predictions = predict(model1, model1_dtest)
```

```{r Model 1 : EIR Evaluate}
# Calculate evaluation metrics
mse <- mean((model1_predictions - model1_test_data[[model1_target]])^2)
rmse <- sqrt(mse)
mae <- mean(abs(model1_predictions - model1_test_data[[model1_target]]))
r_squared <- 1 - sum((model1_test_data[[model1_target]] - model1_predictions)^2) / sum((model1_test_data[[model1_target]] - mean(model1_test_data[[model1_target]]))^2)

# Print the evaluation metrics
cat("MSE:", mse, "\n")
cat("RMSE:", rmse, "\n")
cat("MAE:", mae, "\n")
cat("R-squared:", r_squared, "\n")

```
```{r Model 2 : Churn Train/Test Split}
# Sort the data frame by date in ascending order
split_da_profiles <- lapply(da_profiles, function(df) {
  sorted_df <- df[order(df$date), ]
  sorted_df$weekday <- as.numeric(factor(sorted_df$weekday)) - 1
  sorted_df$churn_status <- as.numeric(factor(sorted_df$churn_status)) - 1
  
  split_index <- ceiling(0.7 * nrow(sorted_df))
  
  train_df <- sorted_df[1:split_index, ]
  test_df <- sorted_df[(split_index + 1):nrow(sorted_df), ]
  
  return(list(train_df = train_df, test_df = test_df))
})


```

```{r Model 2 : Churn Train}
# OBJ = binary:logitraw, binary:hinge, binary:logitboost, binary:logloss

# Train individual models for each profile
profile_binary_models <- list()
profile_regression_models = list()

for (i in 1:length(split_da_profiles)) {
  profile <- split_da_profiles[[i]]
  
  # Extract the train and test data for the current profile
  train_df <- profile$train
  test_df <- profile$test
  
  # Define the features and target variable
  model_binary_features <- c("year", "month.x", "day_of_year", "week", "weekday", "days_since_achievement", "n")
  model_binary_target <- "churn_status"
  
  model_regression_features <- c("year", "month.x", "day_of_year", "week", "weekday", "n")
  model_regression_target <- "days_since_achievement"
  
  # Convert the train data to a matrix
  train_binary_matrix <- as.matrix(train_df[, model_binary_features])
  train_regression_matrix <- as.matrix(train_df[, model_regression_features])
  
  test_binary_matrix <- as.matrix(test_df[, model_binary_features])
  test_regression_matrix <- as.matrix(test_df[, model_regression_features])
  
  # Create the DMatrix for training
  dtrain_binary <- xgb.DMatrix(data = train_binary_matrix, label = train_df[[model_binary_target]])
  dtrain_regression <- xgb.DMatrix(data = train_regression_matrix, label = train_df[[model_regression_target]])
  
  dtest_binary <- xgb.DMatrix(data = test_binary_matrix, label = test_df[[model_binary_target]])
  dtest_regression <- xgb.DMatrix(data = test_regression_matrix, label = test_df[[model_regression_target]])
  
  # Set the hyperparameters for the XGBoost model
  binary_params <- list(
    objective = "binary:logistic",  # Binary classification task
    max_depth = 6,  # Maximum tree depth
    eta = 0.1,  # Learning rate
    subsample = 0.8,  # Subsample ratio
    colsample_bytree = 0.8  # Feature subsampling ratio
  )
  
  regression_params = list(
    objective = "reg:squarederror",  # Regression task
    max_depth = 6,  # Maximum tree depth
    eta = 0.1,  # Learning rate
    subsample = 0.8,  # Subsample ratio
    colsample_bytree = 0.8  # Feature subsampling ratio
  )
  
  # Train the XGBoost model
  binary_model <- xgb.train(params = binary_params, data = dtrain_binary, nrounds = 100)
  regression_model <- xgb.train(params = regression_params, data = dtrain_regression, nrounds = 100)
  
  # Store the trained models
  profile_binary_models[[i]] = binary_model
  profile_regression_models[[i]] = regression_model
}


```

```{r Model 2 : Churn Predictions}
# Initialize lists to store predictions and actual values
all_binary_predictions <- list()
all_regression_predictions <- list()

all_binary_actuals <- list()
all_regression_actuals = list()

# Iterate over the models and make predictions
for (i in 1:length(profile_binary_models)) {
  # Get the current binary classification and regression models, and test data for the profile
  binary_model <- profile_binary_models[[i]]
  regression_model <- profile_regression_models[[i]]
  test_df <- split_da_profiles[[i]]$test
  
  # Define the binary classification features and target variable
  binary_features <- c("year", "month.x", "day_of_year", "week", "weekday", "days_since_achievement", "n")
  binary_target <- "churn_status"
  
  # Define the regression features and target variable
  regression_features <- c("year", "month.x", "day_of_year", "week", "weekday", "n")
  regression_target <- "days_since_achievement"
  
  # Convert the test data to matrices
  binary_matrix <- as.matrix(test_df[, binary_features])
  regression_matrix <- as.matrix(test_df[, regression_features])
  
  # Create the DMatrix for prediction
  dbinary <- xgb.DMatrix(data = binary_matrix)
  dregression <- xgb.DMatrix(data = regression_matrix)
  
  # Make predictions using the models
  binary_predictions <- predict(binary_model, dbinary)
  regression_predictions <- predict(regression_model, dregression)
  
  # Store the predictions and actual values
  all_binary_predictions[[i]] <- binary_predictions
  all_regression_predictions[[i]] <- regression_predictions
  
  all_binary_actuals[[i]] <- test_df[[binary_target]]
  all_regression_actuals[[i]] <- test_df[[regression_target]]
}

# Apply threshold to convert binary probabilities to class labels
all_binary_predicted_labels <- lapply(all_binary_predictions, function(pred) ifelse(pred > 0.5, 1, 0))


```

```{r Model 2 : Churn Evaluate}

confusion_matrices <- lapply(1:length(all_binary_predicted_labels), function(i) {
  predicted <- factor(all_binary_predicted_labels[[i]], levels = c(0, 1), labels = c("Active", "Churned"))
  actual <- factor(all_actuals[[i]], levels = c(0, 1), labels = c("Active", "Churned"))
  confusionMatrix(predicted, actual)
})

evaluation_metrics <- lapply(confusion_matrices, function(cm) {
  cm_summary <- cm$byClass
  return(cm_summary)
})

# Initialize lists to store evaluation metrics
regression_eval_metrics <- list()

# Iterate over the regression predictions and actual values
for (i in 1:length(all_regression_predictions)) {
  # Get the current regression predictions and actual values
  predictions <- all_regression_predictions[[i]]
  actuals <- all_regression_actuals[[i]]
  
  # Calculate evaluation metrics
  mae <- mean(abs(predictions - actuals))
  rmse <- sqrt(mean((predictions - actuals)^2))
  
  # Store the evaluation metrics
  regression_eval_metrics[[i]] <- list(MAE = mae, RMSE = rmse, R_squared = r_squared)
}

# Print the evaluation metrics
for (i in 1:length(regression_eval_metrics)) {
  cat("Profile", i, "Evaluation Metrics:\n")
  cat("MAE:", regression_eval_metrics[[i]]$MAE, "\n")
  cat("RMSE:", regression_eval_metrics[[i]]$RMSE, "\n")
}


```


```{r Model 2 : Forecast}
for (i in 1:length(split_da_profiles)) {
  profile <- split_da_profiles[[i]]
  
  # Extract the train and test data for the current profile
  train_df <- profile$train
  test_df <- profile$test
  
  # Create time series objects for the train and test data
  train_ts <- ts(train_df$churn_status)
  test_ts <- ts(test_df$churn_status)
  
  # Build the forecasting model
  model <- auto.arima(train_ts)
  
  # Make predictions
  forecast <- forecast(model, h = length(test_ts))
  
  # Print the forecasted values
  print(forecast)
}

```

```{r RQ2 : Churn Ratios}
total_observations <- 0

for (profile in da_profiles) {
  total_observations <- total_observations + nrow(profile)
}

print(paste("Total observations across all profiles:", total_observations))

total_observations <- 0

for (profile in da_profiles) {
  if ("Active" %in% profile$churn_status && "Churned" %in% profile$churn_status) {
    print(table(profile$churn_status))
    total_observations <- total_observations + nrow(profile)
  }
}

print(paste("Total observations:", total_observations))

```

```{r EDA Leaderboard}
plot_lb_range(lb_df, "Score", 0, 4000000, 50000, 1000000)
plot_lb_range(lb_df, "Score", 0, 250000, 10000, 25000)
plot_lb_range(lb_df, "Score", 250000, 500000, 10000, 25000)
plot_lb_range(lb_df, "Score", 500000, 1000000, 50000, 50000)
plot_lb_range(lb_df, "Score", 1000000, 2000000, 50000, 100000)
```

# 1.) Game Time Total 
calculate_game_time_total = function(rnd_gamers, directory_df) {
  game_times_list = list()
  
  # Loop through each data frame in rnd_gamers
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag = rnd_gamers[[3]][i]
    games = rnd_gamers[[2]][i]
    games = data.frame(games)
    
    # Extract the hours_played column
    game_hours = games$game_hours_played
    game_minutes = games$game_minutes_played
    
    # Clean the hours_played values and convert to numeric
    cleaned_game_hours = as.numeric(gsub("[^0-9]+", "", game_hours))
    cleaned_game_minutes = as.numeric(gsub("[^0-9]+", "", game_minutes))
    
    # Sum the hours played
    total_game_hours <- sum(cleaned_game_hours, na.rm = TRUE)
    total_game_minutes <- sum(cleaned_game_minutes, na.rm = TRUE)
    
    # Calculate total time in minutes
    total_game_time_minutes <- total_game_hours * 60 + total_game_minutes
    
    # Create a data frame with gamertag and total hours
    game_times_df <- data.frame(gamertag = gamertag, 
                                total_game_hours = total_game_hours, 
                                total_game_minutes = total_game_minutes, 
                                total_game_time_minutes = total_game_time_minutes)
    
    # Add the data frame to the hours_list
    game_times_list[[i]] <- game_times_df
  }
  
  # Combine the data frames from all gamers into a single data frame
  game_times_df <- do.call(rbind, game_times_list)
  
  return(game_times_df)
}

# 2.) App Time Total
calculate_app_time_total = function(rnd_gamers, directory_df) {
  app_times_list = list()
  
  # Loop through each data frame in rnd_gamers
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag = rnd_gamers[[3]][i]
    games = rnd_gamers[[2]][i]
    games = data.frame(games)
    
    # Extract the app_hours_played and app_minutes_played columns
    app_hours = games$app_hours_played
    app_minutes = games$app_minutes_played
    
    # Clean the app_hours_played values and convert to numeric
    cleaned_app_hours = as.numeric(gsub("[^0-9]+", "", app_hours))
    cleaned_app_minutes = as.numeric(gsub("[^0-9]+", "", app_minutes))
    
    # Sum the app hours played
    total_app_hours <- sum(cleaned_app_hours, na.rm = TRUE)
    total_app_minutes <- sum(cleaned_app_minutes, na.rm = TRUE)
    
    # Calculate total app time in minutes
    total_app_time_minutes <- total_app_hours * 60 + total_app_minutes
    
    # Create a data frame with gamertag and total app hours
    app_times_df <- data.frame(gamertag = gamertag, 
                               total_app_hours = total_app_hours, 
                               total_app_minutes = total_app_minutes, 
                               total_app_time_minutes = total_app_time_minutes)
    
    # Add the data frame to the app_times_list
    app_times_list[[i]] <- app_times_df
  }
  
  # Combine the data frames from all gamers into a single data frame
  app_times_df <- do.call(rbind, app_times_list)
  
  return(app_times_df)
}



```{r EDA Profiles Achievement Variables Plots}
# Scatter plot
ggplot(metrics_df, aes(x = longest_gap_within, y = total_game_time_minutes)) +
  geom_point() +
  labs(x = "Longest Gap Within", y = "Total Game Time (Minutes)") +
  ggtitle("Scatter Plot: Longest Gap Within vs. Total Game Time (Minutes)")

ggplot(metrics_df, aes(x = average_interval, y = total_game_time_minutes)) +
  geom_point() +
  labs(x = "Average Interval between Achievements (Daily) ", y = "Total Game Time (Minutes)") +
  ggtitle("Scatter Plot: Average Interval between Achievements (Daily) vs. Total Game Time (Minutes)")

ggplot(metrics_df, aes(x = median_interval, y = total_game_time_minutes)) +
  geom_point() +
  labs(x = "Median Interval between Achievements (Daily) ", y = "Total Game Time (Minutes)") +
  ggtitle("Scatter Plot: Median Interval between Achievements (Daily) vs. Total Game Time (Minutes)")

```