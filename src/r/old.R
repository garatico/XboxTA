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
