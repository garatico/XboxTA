

get_cv_folds = function(target_data, fold_count) {
  cv_folds_full <- vector("list", length(target_data))  # Initialize with the correct length
  
  for (profile in 1:length(target_data)) {
    total_length = nrow(target_data[[profile]])
    # Calculate the size of each fold's testing data
    test_size <- floor(total_length / (fold_count + 1))
    # Calculate the remaining data points
    remaining_points <- total_length %% (fold_count + 1)
    # Create an empty list to store the folds
    cv_folds <- list()
    # Generate cross-validation folds
    for (i in 1:fold_count) {
      # Calculate the indices for the training and testing data
      train_start <- 1
      train_end <- i * test_size
      test_start <- train_end + 1
      test_end <- test_start + test_size - 1
      
      # Adjust the indices for the last fold if there are remaining points
      if (i == fold_count && remaining_points > 0) {
        train_end <- train_end + remaining_points
        test_end <- test_end + remaining_points
      }
      
      # Combine the training and testing indices
      train_indices <- train_start:train_end
      test_indices <- test_start:test_end
      
      # Store the fold indices in the cv_folds list
      cv_folds[[i]] <- list(train = train_indices, test = test_indices)
    }
    cv_folds_full[[profile]] = cv_folds
  }
  return(cv_folds_full)
}


# TARGET 1
train_cv_target1_models = function(profile_index, target_cv_folds, params, data_list, dtrain_list, nrounds) {
  target_models = list()
  all_predictions = list()
  
  all_rmse <- numeric(length(target_cv_folds[[profile_index]]))
  all_mape <- numeric(length(target_cv_folds[[profile_index]]))
  all_smape <- numeric(length(target_cv_folds[[profile_index]]))
  all_model_metrics <- list(all_rmse, all_mape, all_smape)
  
  for (i in 1:length(target_cv_folds[[profile_index]])) {
    # Get the training set and corresponding test set for this fold
    train_indices <- target_cv_folds[[profile_index]][[i]][["train"]]
    test_indices <- target_cv_folds[[profile_index]][[i]][["test"]]
    
    # Subset the dtrain using the fold indices
    train_set <- dtrain_list[[profile_index]][train_indices, ]
    test_set <- dtrain_list[[profile_index]][test_indices, ]
    
    #print(paste0("FOLD: ", i, " Reached"))
    # Train the model on the training set
    
    target_model <- xgb.train(params = params, data = train_set, nrounds = nrounds)
    
    # Store the trained model
    target_models[[i]] <- target_model
    
    # Make predictions on the test set using the trained model
    predictions <- predict(target_models[[i]], newdata = test_set)
    
    # Store the predictions for this fold
    all_predictions[[i]] <- predictions
    actual <- data_list[[profile_index]][test_indices, ]$target
    
    rmse <- sqrt(mean((actual - predictions)^2))
    mape <- mean(abs((actual - predictions) / actual)) * 100
    smape <- mean(2 * abs(actual - predictions) / (abs(actual) + abs(predictions))) * 100
    
    # Store the performance metrics for this fold
    all_model_metrics[[1]][i] <- rmse
    all_model_metrics[[2]][i] <- mape
    all_model_metrics[[3]][i] <- smape
  }
  mean_rmse = mean(all_model_metrics[[1]])
  mean_mape = mean(all_model_metrics[[2]])
  mean_smape = mean(all_model_metrics[[3]])
  print(paste0("PROFILE: ", profile_index, " Complete"))
  return(list(target_models, all_predictions, all_model_metrics, mean_rmse, mean_mape, mean_smape))
}

# TARGET 5
train_cv_target5_models <- function(profile_index, target_cv_folds, params, data_list, dtrain_list, nrounds) {
  target_models <- list()
  all_predictions <- list()
  all_confusion_matrices <- list()
  summed_confusion_matrix <- matrix(0, nrow = 2, ncol = 2)  # Initialize summed confusion matrix
  
  # Initialize variables for performance metrics
  all_accuracy <- c()
  all_precision <- c()
  all_recall <- c()
  all_f1_score <- c()
  
  for (i in 1:length(target_cv_folds[[profile_index]])) {
    # Get the training set and corresponding test set for this fold
    train_indices <- target_cv_folds[[profile_index]][[i]][["train"]]
    test_indices <- target_cv_folds[[profile_index]][[i]][["test"]]
    
    # Subset the dtrain using the fold indices
    train_set <- dtrain_list[[profile_index]][train_indices, ]
    test_set <- dtrain_list[[profile_index]][test_indices, ]
    
    # Train the model on the training set
    target_model <- xgboost(params = params, data = train_set, nrounds = nrounds, verbose = 0)
    
    # Store the trained model
    target_models[[i]] <- target_model
    
    # Make predictions on the test set using the trained model
    predictions <- predict(target_models[[i]], newdata = test_set, type = "prob")
    
    # Store the predictions for this fold
    all_predictions[[i]] <- predictions
    actual <- data_list[[profile_index]][test_indices, ]$target
    
    # Convert predicted and actual values to factors with two levels
    predicted_factors <- factor(predictions > 0.5, levels = c(FALSE, TRUE), labels = c("0", "1"))
    actual_factors <- factor(actual > 0.5, levels = c(FALSE, TRUE), labels = c("0", "1"))
    
    # Create a confusion matrix using caret
    confusion_matrix <- caret::confusionMatrix(predicted_factors, actual_factors)
    # Update the summed confusion matrix
    summed_confusion_matrix <- summed_confusion_matrix + confusion_matrix$table
    
    # Calculate performance metrics for this fold's confusion matrix
    accuracy <- confusion_matrix$overall["Accuracy"]
    precision <- confusion_matrix$byClass["Pos Pred Value"]
    recall <- confusion_matrix$byClass["Sensitivity"]
    f1_score <- confusion_matrix$byClass["F1"]
    
    # Store performance metrics for this fold
    all_accuracy <- c(all_accuracy, accuracy)
    all_precision <- c(all_precision, precision)
    all_recall <- c(all_recall, recall)
    all_f1_score <- c(all_f1_score, f1_score)
    
    # Store the confusion matrix for this fold
    all_confusion_matrices[[i]] <- confusion_matrix
  }
  
  # Calculate performance metrics for the summed confusion matrix
  summed_accuracy <- summed_confusion_matrix[1, 1] / sum(summed_confusion_matrix)
  summed_precision <- summed_confusion_matrix[1, 1] / (summed_confusion_matrix[1, 1] + summed_confusion_matrix[2, 1])
  summed_recall <- summed_confusion_matrix[1, 1] / (summed_confusion_matrix[1, 1] + summed_confusion_matrix[1, 2])
  summed_f1_score <- 2 * summed_precision * summed_recall / (summed_precision + summed_recall)
  
  print(paste0("PROFILE: ", profile_index, " Complete"))
  
  return(list(
    target_models,
    all_predictions,
    all_confusion_matrices,
    summed_confusion_matrix,
    all_accuracy,
    all_precision,
    all_recall,
    all_f1_score,
    summed_accuracy,
    summed_precision,
    summed_recall,
    summed_f1_score
  ))
}
