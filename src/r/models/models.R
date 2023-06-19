

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



train_cv_target_models = function() {
  
}


