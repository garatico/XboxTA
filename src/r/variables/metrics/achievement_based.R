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
    
    achievements_last_scraped <- if (length(matching_index) > 0) {
      as.Date(directory_df$Achievements.Last.Scraped[matching_index], format = "%Y-%m-%d")
    } else {
      NA
    }
    
    achievements <- rnd_gamers[[1]][[i]]
    last_achievement <- max(achievements$achievement_earned)
    
    churned <- ifelse(length(matching_index) > 0,
                      difftime(last_achievement, achievements_last_scraped, units = "days") < -365,
                      NA)
    
    days_since_last <- ifelse(length(matching_index) > 0,
                              as.integer(achievements_last_scraped - last_achievement),
                              NA)
    
    churn_row <- data.frame(gamertag = gamertag, churned = churned, days_since_last = days_since_last)
    churn_df <- rbind(churn_df, churn_row)
  }
  
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
      achievements_last_scraped <- as.Date(directory_df$Achievements.Last.Scraped[directory_df$gamertag == gamertag], format = "%Y-%m-%d")
      
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




