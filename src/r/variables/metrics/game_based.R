# =====================
# GAMES BASED VARIABLES
calculate_gameapp_time_total <- function(rnd_gamers, directory_df, time_type) {
  time_list <- list()
  
  # Loop through each data frame in rnd_gamers
  for (i in 1:length(rnd_gamers[[3]])) {
    gamertag <- rnd_gamers[[3]][i]
    games <- rnd_gamers[[2]][i]
    games <- data.frame(games)
    
    if (time_type == "game") {
      hours_column <- "game_hours_played"
      minutes_column <- "game_minutes_played"
      label <- "game"
    } else if (time_type == "app") {
      hours_column <- "app_hours_played"
      minutes_column <- "app_minutes_played"
      label <- "app"
    } else {
      stop("Invalid time_type specified. Must be either 'game' or 'app'.")
    }
    
    # Extract the hours and minutes columns
    hours <- games[[hours_column]]
    minutes <- games[[minutes_column]]
    
    # Clean the hours and minutes values and convert to numeric
    cleaned_hours <- as.numeric(gsub("[^0-9]+", "", hours))
    cleaned_minutes <- as.numeric(gsub("[^0-9]+", "", minutes))
    
    # Sum the hours and minutes separately
    total_hours <- sum(cleaned_hours, na.rm = TRUE)
    total_minutes <- sum(cleaned_minutes, na.rm = TRUE)
    
    # Calculate the total time in minutes
    total_time_minutes <- total_hours * 60 + total_minutes
    
    # Create a data frame with gamertag and total time
    time_df <- data.frame(
      gamertag = gamertag,
      setNames(list(total_hours), paste0("total_", label, "_hours")),
      setNames(list(total_minutes), paste0("total_", label, "_minutes")),
      setNames(list(total_time_minutes), paste0("total_", label, "_time_minutes"))
    )
    
    # Add the data frame to the time_list
    time_list[[i]] <- time_df
  }
  
  # Combine the data frames from all gamers into a single data frame
  time_df <- do.call(rbind, time_list)
  
  return(time_df)
}







