source("./src/r/transformations/achievement.R")
source("./src/r/transformations/game_feature_transformations.R")

# ==========================
# LEADERBOARD TRANSFORMATIONS
lb_feature_transformations = function(lb_df) {
  lb_df$Score = gsub(',', '', lb_df$Score)             # Remove commas
  lb_df$Score = as.numeric(as.character(lb_df$Score))  # Convert one variable to numeric
  return(lb_df)
}



# =========================
# DIRECTORY TRANSFORMATIONS
directory_transformations = function(directory_df) {
  directory_df$Achievements.Last.Scraped = ifelse(
    grepl("/", directory_df$Achievements.Last.Scraped),
    format(as.POSIXct(directory_df$Achievements.Last.Scraped, format = "%m/%d/%Y %H:%M"), "%Y-%m-%d"),
    format(as.POSIXct(directory_df$Achievements.Last.Scraped, format = "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d")
  )
  directory_df$Games.Last.Scraped = ifelse(
    grepl("/", directory_df$Games.Last.Scraped),
    format(as.POSIXct(directory_df$Games.Last.Scraped, format = "%m/%d/%Y %H:%M"), "%Y-%m-%d"),
    format(as.POSIXct(directory_df$Games.Last.Scraped, format = "%Y-%m-%d %H:%M:%S"), "%Y-%m-%d")
  )
  return(directory_df)
}













