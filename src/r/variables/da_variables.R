# =====================
# DAILY ACHIEVEMENTS TABLE
calculate_daily_achievements <- function(df) {
  # Pivot the data to calculate daily achievements
  df <- df %>%
    pivot_wider(names_from = data_frame_id, values_from = n)
  
  # Rename columns
  col_names <- names(df)
  named_cols <- col_names[1:5]
  num_cols <- col_names[6:length(col_names)]
  num_cols <- paste0("profile_", 1:length(num_cols))
  new_col_names <- c(named_cols, num_cols)
  colnames(df)[6:length(col_names)] <- new_col_names[6:length(col_names)]
  
  # Convert year to numeric
  df$year <- as.numeric(df$year)
  
  # Convert month to numeric
  df$month <- as.numeric(as.character(df$month))
  
  # Get the minimum and maximum years from the original data frame
  min_year <- min(df$year)
  max_year <- max(df$year)
  
  # Get the minimum and maximum dates from the original data frame
  min_date <- min(paste0(df$year, formatC(df$day_of_year, width = 3, flag = "0")))
  max_date <- max(paste0(df$year, formatC(df$day_of_year, width = 3, flag = "0")))
  
  # Create a sequence of dates from the minimum to maximum date
  all_dates <- data.frame(date = seq(as.Date(min_date, format = "%Y%j"), as.Date(max_date, format = "%Y%j"), by = "day"))
  
  # Extract year, month, and day of year from all dates
  all_dates <- all_dates %>%
    mutate(year = year(date),
           month = month(date),
           day_of_year = yday(date),
           week = week(date))
  
  # Merge the original data frame with all dates
  df <- all_dates %>%
    filter(year >= min_year & year <= max_year) %>%
    left_join(df, by = c("year", "day_of_year", "week"))
  
  # Drop the redundant month.y column
  df <- df[, !names(df) %in% c("month.y")]
  return(df)
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

da_fill_dates2 <- function(df) {
  # Convert the input data frame to a data.table for faster operations
  dt <- as.data.table(df)
  
  # Convert the date_column to Date format
  dt[, date := as.Date(date)]
  
  # Create a new column called "Weekday" and initialize it with NA values
  dt[, weekday := NA]
  
  # Iterate over each profile column
  profile_columns <- grep("^profile_", names(dt), value = TRUE)
  for (col in profile_columns) {
    non_na_indices <- which(!is.na(dt[[col]]))
    if (length(non_na_indices) > 0) {
      first_non_na_index <- non_na_indices[1]
      dt[first_non_na_index:nrow(dt), (col) := replace(.SD, is.na(.SD), 0), .SDcols = col]
    }
  }
  
  
  # Assign weekdays based on the date column
  dt[, weekday := ifelse(weekdays(date) %in% c("Saturday", "Sunday"), "Weekend", "Weekday")]
  
  return(as.data.frame(dt))
}

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

da_split_by_profile2 <- function(df) {
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

da_profile_set_churn_status2 <- function(df) {
  # Convert the input data frame to a data.table
  dt <- as.data.table(df)
  
  # Subset the data.table to remove rows with missing values in the 'n' column
  dt <- dt[!is.na(n)]
  
  # Convert the date column to a Date format
  dt[, date := as.Date(date)]
  
  # Create new columns called "churn_status" and "days_since_achievement"
  dt[, `:=`(churn_status = "Active", churn_binary = 0, days_since_achievement = 0)]
  
  # Initialize variables
  churned <- FALSE
  days_since_achievement <- 0
  
  # Iterate over each row in the data.table
  dt[, {
    # Check if n is 0
    if (n == 0) {
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
      churn_status <- "Churned"
      churn_binary <- 1
    } else {
      churn_status <- "Active"
      churn_binary <- 0
    }
    days_since_achievement <- days_since_achievement
    
    .(churn_status, churn_binary, days_since_achievement)
  }, by = 1:nrow(dt)]
  
  # Convert the data.table back to a data frame
  df <- as.data.frame(dt)
  
  return(df)
}

da_profiles_set_churn <- function(da_profiles) {
  valid_profiles <- c()
  
  for (i in 1:length(da_profiles)) {
    df <- da_profiles[[i]]
    df <- df[!is.na(df$n), ]
    
    if (nrow(df) > 0) {
      da_profiles[[i]] <- da_profile_set_churn_status(da_profiles[[i]])
      valid_profiles <- c(valid_profiles, i)
    } else {
      print(paste0("PROFILE: ", i, " DROPPED (All NA values)"))
    }
  }
  
  return(da_profiles[valid_profiles])
}

da_profiles_set_days_existence <- function(da_profiles) {
  da_profiles <- lapply(da_profiles, function(df) {
    df$profile_days <- 1:nrow(df)
    return(df)
  })
  return(da_profiles)
}

calculate_daily_lt_eir <- function(da_profiles) {
  for (i in 1:length(da_profiles)) {
    df <- da_profiles[[i]]
    df$daily_lt_eir <- cumsum(df$n) / df$profile_days
    df$cumulative_n <- cumsum(df$n)
    da_profiles[[i]] <- df
  }
  return(da_profiles)
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

calculate_weekly_eir_all2 <- function(da_profiles) {
  updated_profiles <- lapply(da_profiles, function(df) {
    weekly_eir <- df %>%
      group_by(week, year) %>%
      summarize(cumulative_n_week = sum(n),
                days_in_week = n(), .groups = "drop") %>%
      mutate(weekly_eir = ifelse(cumulative_n_week == 0, 0, cumulative_n_week / days_in_week))
    
    # Merge weekly EIR with the original data frame
    df <- merge(df, weekly_eir, by = c("week", "year"), all.x = TRUE)
    
    return(df)
  })
  
  return(updated_profiles)
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

calculate_monthly_eir_all2 <- function(da_profiles) {
  updated_profiles <- lapply(da_profiles, function(df) {
    monthly_eir <- df %>%
      group_by(year, month.x) %>%
      summarize(cumulative_n_month = sum(n),
                days_in_month = n_distinct(day_of_year), .groups = "drop") %>%
      mutate(monthly_eir = ifelse(cumulative_n_month == 0, 0, cumulative_n_month / days_in_month))
    # Merge monthly EIR with the original data frame
    df <- merge(df, monthly_eir, by = c("year", "month.x"), all.x = TRUE)
    
    return(df)
  })
  
  return(updated_profiles)
}





