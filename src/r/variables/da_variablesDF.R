da_split_by_profile <- function(df) {
  # Create a list to store the split DataFrames
  df_list <- list()
  
  # Extract the first 6 columns that should be kept in all split DataFrames
  common_cols <- df[, 1:6]
  
  # Find the column indices that start with "profile_"
  profile_cols <- grep("^profile_", names(df))
  
  # Iterate over each profile column and create a separate DataFrame
  for (col in profile_cols) {
    # Extract the profile column and combine it with the common columns
    split_df <- cbind(common_cols, n = df[, col])
    
    # Add the split DataFrame to the list
    df_list[[col - 6]] <- split_df
  }
  
  return(df_list)
}

calculate_monthly_eir_all <- function(da_profiles) {
  updated_profiles <- lapply(da_profiles, function(df) {
    monthly_eir <- df %>%
      group_by(year, month.x) %>%
      summarize(cumulative_n_month = sum(n),
                days_in_month = n_distinct(day_of_year)) %>%
      mutate(monthly_eir = ifelse(cumulative_n_month == 0, 0, cumulative_n_month / days_in_month))
    
    # Merge monthly EIR with the original data frame
    df <- merge(df, monthly_eir, by = c("year", "month.x"), all.x = TRUE)
    
    return(df)
  })
  
  return(updated_profiles)
}

calculate_weekly_eir_all <- function(da_profiles) {
  updated_profiles <- lapply(da_profiles, function(df) {
    weekly_eir <- df %>%
      group_by(week, year) %>%
      summarize(cumulative_n_week = sum(n),
                days_in_week = n()) %>%
      mutate(weekly_eir = ifelse(cumulative_n_week == 0, 0, cumulative_n_week / days_in_week))
    
    # Merge weekly EIR with the original data frame
    df <- merge(df, weekly_eir, by = c("week", "year"), all.x = TRUE)
    
    return(df)
  })
  
  return(updated_profiles)
}



da_fill_dates <- function(df) {
  # Convert the date_column to Date format
  df[["date"]] <- as.Date(df[["date"]])
  
  # Create a new column called "Weekday" and initialize it with NA values
  df$weekday <- NA
  
  profile_columns <- grep("^profile_", names(df), value = TRUE)
  
  # Iterate over each profile column
  for (col in profile_columns) {
    col_values <- df[[col]]
    first_non_na_index <- which(!is.na(col_values))[1]
    
    if (!is.na(first_non_na_index)) {
      # Replace NAs after the first non-NA value with 0
      non_na_encountered <- FALSE
      
      for (i in 1:length(col_values)) {
        if (is.na(col_values[i])) {
          if (non_na_encountered) {
            df[[col]][i] <- 0
          }
        } else {
          non_na_encountered <- TRUE
        }
      }
    }
  }
  
  # Assign weekdays based on the date column
  df$weekday <- ifelse(weekdays(df[["date"]]) %in% c("Saturday", "Sunday"), "Weekend", "Weekday")
  
  return(df)
}

da_profile_set_churn_status <- function(df) {
  df = df[!is.na(df$n), ]
  
  # Convert the date column to a Date format
  df$date <- as.Date(df$date)
  
  # Create a new column called "churn_status" and initialize it with "Active"
  df$churn_status <- "Active"
  df$churn_binary = 0
  
  # Create a new column called "days_since_achievement" and initialize it with 0
  df$days_since_achievement <- 0
  
  # Initialize variables
  churned <- FALSE
  days_since_achievement <- 0
  
  # Iterate over each row in the data frame
  for (i in 1:nrow(df)) {
    # Check if n is 0
    if (df$n[i] == 0) {
      # Check if it has been 365 consecutive days with n = 0
      if (days_since_achievement >= 365) {
        churned <- TRUE
      }
      days_since_achievement <- days_since_achievement + 1
    } else {
      # Reset the days counter and churned status
      days_since_achievement <- 0
      churned <- FALSE
    }
    
    # Set the churn status and days since achievement
    if (churned) {
      df$churn_status[i] <- "Churned"
      df$churn_binary[i] = 1
    } else {
      df$churn_status[i] <- "Active"
      df$churn_binary[i] = 0
    }
    df$days_since_achievement[i] <- days_since_achievement
  }
  
  return(df)
}







