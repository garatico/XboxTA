update_achievement_masterlist = function(rnd_achievements) {
  # Check if "achievements_masterlist.csv" exists
  if (file.exists("./data/achievements_masterlist.csv")) {
    # Read the existing file
    existing_achievements = read.csv("./data/achievements_masterlist.csv")
    
    # Combine with new achievements
    combined_achievements = rbind(existing_achievements, rnd_achievements)
    
    # Filter for unique values
    unique_achievements = unique(combined_achievements)
    
    # Write the updated data frame to the file
    write.csv(unique_achievements, "./data/achievements_masterlist.csv", row.names = FALSE)
    
    rm(combined_achievements)
    rm(existing_achievements)
    rm(unique_achievements)
  } else {
    # File doesn't exist, write the new achievements directly
    new_achievements = combine_achievements(rnd_gamers)
    write.csv(new_achievements, "./data/achievements_masterlist.csv", row.names = FALSE)
    rm(new_achievements)
  }
}

achievement_combine_achievements = function(rnd_gamers) {
  # Create an empty data frame to store the achievements
  master_achievements <- data.frame()
  
  # Iterate through each data frame in rnd_gamers
  for (df in rnd_gamers) {
    # Drop the "achievement_earned" column from the data frame
    df_achievements <- df[, -which(names(df) == "achievement_earned")]
    
    # Remove "?gamerid=nnnnnnn" from the end of game_url
    df_achievements$achievement_game_url <- gsub("\\?gamerid=\\d+$", "", df_achievements$achievement_game_url)
    
    # Remove "#nnnnnn" from the end of achievement_url
    df_achievements$achievement_url <- gsub("#\\d+$", "", df_achievements$achievement_url)
    
    
    # Combine the achievements with the master data frame
    master_achievements <- rbind(master_achievements, df_achievements)
  }
  
  return(master_achievements)
}


