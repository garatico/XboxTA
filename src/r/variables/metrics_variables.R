# Time Series Metrics
# ===============
# TOTAL PROCESSING 
process_metrics_df = function(rnd_gamers, directory_df) {
  # ACHIEVEMENTS BASED
  churn_df = calculate_churn(rnd_gamers, directory_df)
  longest_gap_within_df = calculate_longest_gap_within(rnd_gamers, directory_df)
  longest_daily_streak_df = calculate_longest_daily_streak(rnd_gamers, directory_df)
  average_daily_interval_df = calculate_average_daily_interval(rnd_gamers, directory_df)
  median_daily_interval_df = calculate_median_daily_interval(rnd_gamers, directory_df)
  days_since_first_df = calculate_days_since_first_achievement(rnd_gamers, directory_df)
  # GAMES BASED
  game_times_df = calculate_game_time_total(rnd_gamers, directory_df)
  app_times_df = calculate_app_time_total(rnd_gamers, directory_df)
  
  # Merge metric data frames
  metrics_df = merge(churn_df, longest_gap_within_df, by = "gamertag", all = TRUE)
  metrics_df = merge(metrics_df, longest_daily_streak_df, by = "gamertag", all = TRUE)
  metrics_df = merge(metrics_df, average_daily_interval_df, by = "gamertag", all = TRUE)
  metrics_df = merge(metrics_df, median_daily_interval_df, by = "gamertag", all = TRUE)
  metrics_df = merge(metrics_df, days_since_first_df, by = "gamertag", all = TRUE)
  
  metrics_df = merge(metrics_df, game_times_df, by = "gamertag", all = TRUE)
  metrics_df = merge(metrics_df, app_times_df, by = "gamertag", all = TRUE)
  
  # Return the metrics data frame
  return(metrics_df)
}



# ===========================
# ACHIEVEMENT BASED VARIABLES
# 1.) Churn @ 365 days
calculate_churn = function(rnd_gamers, directory_df) {
  churn_df <- data.frame(gamertag = character(),
                         churned = logical(),
                         days_since_last = integer(),
                         stringsAsFactors = FALSE)
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    matching_index <- which(directory_df$gamertag == gamertag)
    
    if (length(matching_index) > 0) {
      # Extract last scraped date
      achievements_last_scraped <- tryCatch(
        {
          parsed_dates <- parse_date_time(directory_df$Achievements.Last.Scraped[matching_index], orders = c("Ymd HMS", "mdY HM"))
          as.Date(parsed_dates, format = "%Y-%m-%d")
        },
        error = function(e) {
          NA
        }
      )
      
      # Read achievements data for the gamer
      achievements <- rnd_gamers[[1]][[i]]
      
      # Calculate churn based on last scraped date and last achievement earned
      last_achievement = max(achievements$achievement_earned)
      churned = last_achievement < achievements_last_scraped - 365
      days_since_last = as.integer(achievements_last_scraped - last_achievement)
      # Create a row for the churn data
      churn_row <- data.frame(gamertag = gamertag, churned = churned, days_since_last = days_since_last)
      
      # Append the churn row to the churn data frame
      churn_df <- rbind(churn_df, churn_row)
    } else {
      # Handle case when matching index is not found
      churn_row <- data.frame(gamertag = gamertag, churned = NA, days_since_last = NA)
      churn_df <- rbind(churn_df, churn_row)
    }
  }
  
  # Return the churn data frame
  return(churn_df)
}

# 2.) Achievement Gap Longest Within
calculate_longest_gap_within = function(rnd_gamers, directory_df) {
  gap_list = list()  # List to store gap values
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag = rnd_gamers[[3]][i]
    achievements = rnd_gamers[[1]][[i]]
    
    if (nrow(achievements) > 1) {
      # Sort achievements by date
      achievements = achievements[order(achievements$achievement_earned), ]
      
      # Calculate time differences between consecutive achievements
      time_diff = diff(achievements$achievement_earned)
      
      # Find the longest gap between achievements
      longest_gap_within = max(time_diff)
      
      # Calculate time differences between achievements and last scraped date
      last_scraped_date = as.Date(directory_df$Achievements.Last.Scraped[directory_df$gamertag == gamertag], format = "%Y-%m-%d")
    } else {
      # Handle case when there is only one achievement
      longest_gap_within <- 0
    }
    
    # Store the gap values in a list
    gap_values = list(gamertag = gamertag, longest_gap_within = longest_gap_within)
    gap_list[[i]] = gap_values
  }
  
  # Convert the list to a data frame
  gap_df = do.call(rbind.data.frame, gap_list)
  
  # Return the data frame
  return(gap_df)
}

# 3.) Longest Daily Streak
calculate_longest_daily_streak = function(rnd_gamers, directory_df) {
  streak_list <- list()  # List to store streak values
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    achievements <- rnd_gamers[[1]][[i]]
    
    if (nrow(achievements) > 1) {
      # Sort achievements by date
      achievements <- achievements[order(achievements$achievement_earned), ]
      
      # Calculate time differences between consecutive achievements
      time_diff <- as.numeric(diff(achievements$achievement_earned))
      
      # Find the longest daily streak of earning achievements
      streak <- 1  # Initialize streak counter
      longest_streak <- 1  # Initialize longest streak counter
      
      for (j in 1:(length(time_diff) - 1)) {
        if (time_diff[j + 1] == 1) {
          streak <- streak + 1  # Increase streak if consecutive days
        } else {
          streak <- 1  # Reset streak if not consecutive days
        }
        
        longest_streak <- max(longest_streak, streak)  # Update longest streak
      }
    } else {
      # Handle case when there is only one achievement
      longest_streak <- 1
    }
    
    # Store the streak values in a list
    streak_values <- list(gamertag = gamertag, longest_streak = longest_streak)
    streak_list[[i]] <- streak_values
  }
  
  # Convert the list to a data frame
  streak_df <- do.call(rbind.data.frame, streak_list)
  
  # Return the data frame
  return(streak_df)
}

# 4.) Average Time in Days Between Achievements
calculate_average_daily_interval = function(rnd_gamers, directory_df) {
  interval_list <- list()  # List to store interval values
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    achievements <- rnd_gamers[[1]][[i]]
    
    if (nrow(achievements) > 1) {
      # Sort achievements by date
      achievements <- achievements[order(achievements$achievement_earned), ]
      
      # Calculate time differences between consecutive achievements
      time_diff <- as.numeric(diff(achievements$achievement_earned))
      
      # Calculate average interval between achievements
      average_interval <- mean(time_diff, na.rm = TRUE)
    } else {
      # Handle case when there is only one achievement
      average_interval <- 0
    }
    
    # Store the interval values in a list
    interval_values <- list(gamertag = gamertag, average_interval = average_interval)
    interval_list[[i]] <- interval_values
  }
  
  # Convert the list to a data frame
  interval_df <- do.call(rbind.data.frame, interval_list)
  
  # Return the data frame
  return(interval_df)
}

# 5.) Median Time in Days Between Achievements
calculate_median_daily_interval = function(rnd_gamers, directory_df) {
  interval_list <- list()  # List to store interval values
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    achievements <- rnd_gamers[[1]][[i]]
    
    if (nrow(achievements) > 1) {
      # Sort achievements by date
      achievements <- achievements[order(achievements$achievement_earned), ]
      
      # Calculate time differences between consecutive achievements in days
      time_diff <- as.numeric(diff(achievements$achievement_earned), units = "days")
      
      # Calculate median interval between achievements, excluding outliers
      median_interval <- median(time_diff[time_diff > 0], na.rm = TRUE)
    } else {
      # Handle case when there is only one achievement
      median_interval <- 0
    }
    
    # Store the interval values in a list
    interval_values <- list(gamertag = gamertag, median_interval = median_interval)
    interval_list[[i]] <- interval_values
  }
  
  # Convert the list to a data frame
  interval_df <- do.call(rbind.data.frame, interval_list)
  
  # Return the data frame
  return(interval_df)
}

# 6.) Calculate Total Days Since First Achievement
calculate_days_since_first_achievement <- function(rnd_gamers, directory_df) {
  days_list <- list()  # List to store days since first achievement
  
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    achievements <- rnd_gamers[[1]][[i]]
    
    if (nrow(achievements) > 0) {
      # Sort achievements by date
      achievements <- achievements[order(achievements$achievement_earned), ]
      
      # Calculate the number of days since the first achievement
      first_achievement_date <- min(achievements$achievement_earned)
      
      # Extract last scraped date
      achievements_last_scraped <- tryCatch(
        {
          parsed_dates <- parse_date_time(directory_df$Achievements.Last.Scraped[directory_df$gamertag == gamertag], orders = c("Ymd HMS", "mdY HM"))
          as.Date(parsed_dates, format = "%Y-%m-%d")
        },
        error = function(e) {
          NA
        }
      )
      
      days_since_first_achievement <- as.numeric(achievements_last_scraped - first_achievement_date)
    } else {
      # Handle case when there are no achievements
      days_since_first_achievement <- NA
    }
    
    # Store the gamertag and days since first achievement in a list
    days_values <- list(gamertag = gamertag, days_since_first_achievement = days_since_first_achievement)
    days_list[[i]] <- days_values
  }
  
  # Convert the list to a data frame
  days_df <- do.call(rbind.data.frame, days_list)
  
  # Return the data frame
  return(days_df)
}

# =====================
# GAMES BASED VARIABLES
# 1.) Game Time Total 
calculate_game_time_total = function(rnd_gamers, directory_df) {
  game_times_list = list()
  
  # Loop through each data frame in rnd_gamers
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag = rnd_gamers[[3]][i]
    games = rnd_gamers[[2]][i]
    games = data.frame(games)
    
    # Extract the hours_played column
    hours = games$hours_played
    minutes = games$minutes_played
    
    # Clean the hours_played values and convert to numeric
    cleaned_hours = as.numeric(gsub("[^0-9]+", "", hours))
    cleaned_minutes = as.numeric(gsub("[^0-9]+", "", minutes))
    
    # Sum the hours played
    total_hours <- sum(cleaned_hours, na.rm = TRUE)
    total_minutes <- sum(cleaned_minutes, na.rm = TRUE)
    
    # Calculate total time in minutes
    total_game_time_minutes <- total_hours * 60 + total_minutes
    
    # Create a data frame with gamertag and total hours
    game_times_df <- data.frame(gamertag = gamertag, total_hours = total_hours, total_minutes = total_minutes, total_game_time_minutes = total_game_time_minutes)
    
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
    app_times_df <- data.frame(gamertag = gamertag, total_app_hours = total_app_hours, total_app_minutes = total_app_minutes, total_app_time_minutes = total_app_time_minutes)
    
    # Add the data frame to the app_times_list
    app_times_list[[i]] <- app_times_df
  }
  
  # Combine the data frames from all gamers into a single data frame
  app_times_df <- do.call(rbind, app_times_list)
  
  return(app_times_df)
}
