# ===========================
# ACHIEVEMENT TRANSFORMATIONS

achievement_transform_dates = function(rnd_gamers, directory_df) {
  # Loop through each data frame in rnd_gamers
  for (i in seq_along(rnd_gamers)) {
    # Drop rows with "Offline", "Today", or "Yesterday"
    rnd_gamers[[i]] = rnd_gamers[[i]][!(rnd_gamers[[i]]$achievement_earned %in% c("Offline", "Yesterday", "Today")), ]
    
    # Convert the date column to Date format
    rnd_gamers[[i]]$achievement_earned = as.Date(rnd_gamers[[i]]$achievement_earned, format = "%d %b %y")
    
    # Extract date metrics
    rnd_gamers[[i]]$month = format(rnd_gamers[[i]]$achievement_earned, "%b")
    rnd_gamers[[i]]$year = format(rnd_gamers[[i]]$achievement_earned, "%Y")
    rnd_gamers[[i]]$week = isoweek(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$day_of_year = yday(rnd_gamers[[i]]$achievement_earned)
    rnd_gamers[[i]]$weekday = ifelse(weekdays(rnd_gamers[[i]]$achievement_earned) %in% c("Saturday", "Sunday"), "Weekend", "Weekday")
  }
  return(rnd_gamers)
}


