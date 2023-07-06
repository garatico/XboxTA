# ===========================
# ACHIEVEMENT TRANSFORMATIONS
achievement_transform_today = function(rnd_gamers, directory_df) {
  for (i in seq_along(rnd_gamers)) {
    # Check if there are rows with "Today" in achievement_earned
    if ("Today" %in% rnd_gamers[[i]]$achievement_earned) {
      # Replace rows with "Today" with achievements scraped date
      today_rows <- rnd_gamers[[i]]$achievement_earned == "Today"
      rnd_gamers[[i]]$achievement_earned[today_rows] <- directory_df$Achievements.Last.Scraped[i]
    }
  }
  return(rnd_gamers)
}

achievement_transform_yesterday = function(rnd_gamers, directory_df) {
  for (i in seq_along(rnd_gamers)) {
    # Check if there are rows with "Yesterday" in achievement_earned
    if ("Yesterday" %in% rnd_gamers[[i]]$achievement_earned) {
      # Get the achievements last scraped date    2023-06-07
      last_scraped_date <- as.Date(directory_df$Achievements.Last.Scraped[i], format = "%Y-%m-%d")
      
      # Calculate yesterday's date
      yesterday <- last_scraped_date - 1
      
      # Convert yesterday's date to the desired format
      yesterday_str <- format(yesterday, "%Y-%m-%d")
      
      # Replace rows with "Yesterday" with yesterday's date
      yesterday_rows <- rnd_gamers[[i]]$achievement_earned == "Yesterday"
      rnd_gamers[[i]]$achievement_earned[yesterday_rows] <- yesterday_str
    }
  }
  return(rnd_gamers)
}

achievement_transform_drop_offline <- function(rnd_gamers) {
  for (i in seq_along(rnd_gamers)) {
    rnd_gamers[[i]] <- rnd_gamers[[i]][rnd_gamers[[i]]$achievement_earned != "Offline", ]
  }
  return(rnd_gamers)
}


achievement_transform_offline_column <- function(rnd_gamers) {
  for (i in seq_along(rnd_gamers)) {
    # Create new column "achievement_type" indicating Online or Offline
    rnd_gamers[[i]]$achievement_type <- ifelse(rnd_gamers[[i]]$achievement_earned == "Offline", "Offline", "Online")
    
    # Replace "achievement_earned" with NA for Offline achievements
    rnd_gamers[[i]]$achievement_earned <- ifelse(rnd_gamers[[i]]$achievement_type == "Offline", NA, rnd_gamers[[i]]$achievement_earned)
  }
  return(rnd_gamers)
}

achievement_transform_interpolate_offline = function(rnd_gamers) {
  
}

achievement_transform_format_dates = function(rnd_gamers) {
  for (i in seq_along(rnd_gamers)) {
    # Check if the date format is "06 Jun 23"
    is_date_format <- grepl("\\d{2} \\w{3} \\d{2}", rnd_gamers[[i]]$achievement_earned)
    
    # Convert the date format "06 Jun 23" to Date object
    date_obj <- as.Date(rnd_gamers[[i]]$achievement_earned, format = "%d %b %y")
    
    # Convert the Date object to the desired format "2023-06-07" for matching rows
    rnd_gamers[[i]]$achievement_earned[is_date_format] <- format(date_obj[is_date_format], "%Y-%m-%d")
  }
  return(rnd_gamers)
}

achievement_transform_extract_dates = function(rnd_gamers) {
  for (i in seq_along(rnd_gamers)) {
    # Convert achievement_earned to Date format
    rnd_gamers[[i]]$achievement_earned <- as.Date(rnd_gamers[[i]]$achievement_earned, format = "%Y-%m-%d")
    
    # Extract date metrics
    rnd_gamers[[i]]$month <- month(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$year <- year(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$week <- isoweek(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$day_of_year <- yday(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$weekday <- ifelse(wday(rnd_gamers[[i]]$achievement_earned) %in% c(1, 7), "Weekend", "Weekday")
  }
  
  return(rnd_gamers)
}









