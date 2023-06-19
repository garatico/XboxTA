source("./src/r/transformations/achievement_feature_transformations.R")
source("./src/r/transformations/game_feature_transformations.R")

# ==========================
# LEADERBOARD TRANSFORMATIONS
lb_feature_transformations = function(lb_df) {
  lb_df$Score = gsub(',', '', lb_df$Score)             # Remove commas
  lb_df$Score = as.numeric(as.character(lb_df$Score))  # Convert one variable to numeric
  return(lb_df)
}





