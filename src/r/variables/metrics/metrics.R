source("./src/r/variables/metrics/achievement_based.R")
source("./src/r/variables/metrics/game_based.R")

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
  game_times_df = calculate_gameapp_time_total(rnd_gamers, directory_df, "game")
  app_times_df = calculate_gameapp_time_total(rnd_gamers, directory_df, "app")
  
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

