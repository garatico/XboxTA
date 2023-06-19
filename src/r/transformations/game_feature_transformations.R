# ===========================
# GAME TRANSFORMATIONS
games_transform_hours = function(rnd_gamers, directory_df) {
  # Loop through each data frame in rnd_gamers
  for (i in seq_along(rnd_gamers)) {
    # Remove time_played for "Defiance 2050"
    game_title = rnd_gamers[[i]]$game_title
    if ("Defiance 2050" %in% game_title) {
      rnd_gamers[[i]]$time_played[game_title == "Defiance 2050"] <- NA
    }
    
    # Extract hours and minutes from time_played
    time_played = rnd_gamers[[i]]$time_played
    
    # Create regular expression patterns for hours and minutes
    hours_pattern <- "([0-9]+)\\s*hr"
    minutes_pattern <- "([0-9]+)\\s*min"
    
    # Extract hours and minutes using regular expressions
    hours <- sapply(regmatches(time_played, gregexpr(hours_pattern, time_played)), function(x) {
      if (length(x) > 0) as.numeric(gsub(hours_pattern, "\\1", x)) else NA
    })
    minutes <- sapply(regmatches(time_played, gregexpr(minutes_pattern, time_played)), function(x) {
      if (length(x) > 0) as.numeric(gsub(minutes_pattern, "\\1", x)) else NA
    })
    
    # Separate hours and minutes for apps like Netflix and YouTube
    is_app <- grepl("Netflix|YouTube|Hulu|Amazon Video|Crackle|Spotify|HBO Max", game_title)
    game_hours <- rep(0, length(game_title))
    game_minutes <- rep(0, length(game_title))
    game_hours[!is_app] <- hours[!is_app]
    game_minutes[!is_app] <- minutes[!is_app]
    
    # Separate app hours and minutes
    app_hours <- rep(0, length(game_title))
    app_minutes <- rep(0, length(game_title))
    app_hours[is_app] <- hours[is_app]
    app_minutes[is_app] <- minutes[is_app]
    
    # Replace missing values with 0
    hours[is.na(hours)] <- 0
    minutes[is.na(minutes)] <- 0
    
    # Assign extracted values to new columns
    rnd_gamers[[i]]$game_hours_played <- game_hours
    rnd_gamers[[i]]$game_minutes_played <- game_minutes
    rnd_gamers[[i]]$app_hours_played <- app_hours
    rnd_gamers[[i]]$app_minutes_played <- app_minutes
  }
  
  return(rnd_gamers)
}

