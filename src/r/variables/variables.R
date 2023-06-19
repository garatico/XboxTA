source("./src/r/variables/metrics_variables.R")
source("./src/r/variables/da_variables.R")


# =====================
# SEPARATE CALCULATIONS
# 1.)
achievement_calculate_frequencies <- function(rnd_gamers) {
  # Define the desired order of months
  month_order <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
  
  # Aggregate the data by month and year and count the occurrences for each data frame
  frequency_dfs <- lapply(rnd_gamers[[1]], function(df) {
    df %>%
      group_by(month, year, week, day_of_year, weekday) %>%
      summarise(n = n(), .groups = 'drop') %>%
      as.data.frame()  # Convert the result to a data frame
  })
  
  # Set the order of months for each data frame
  for (i in seq_along(frequency_dfs)) {
    frequency_dfs[[i]]$month <- factor(frequency_dfs[[i]]$month, levels = month_order)
  }
  return(frequency_dfs)
}

# 2.)
get_total_observations = function(rnd_gamers) {
  total_observations = sum(sapply(rnd_gamers, function(df) dim(df)[1]))
  return(total_observations)
}

# 3.)
calculate_engagement_intensity_ratio <- function(df) {
  df <- df %>%
    group_by(data_frame_id, year, week, month, day_of_year, weekday) %>%
    summarise(total_achievements = sum(n),
              total_days = 7) %>%
    mutate(engagement_ratio = total_achievements / total_days)
  
  return(df)
}

# 4.)
calculate_churn_status <- function(df) {
  df <- df %>%
    group_by(data_frame_id) %>%
    arrange(data_frame_id, year, month, day_of_year) %>%
    mutate(
      last_achievement_date = lag(day_of_year),
      churn_status = ifelse(
        day_of_year - last_achievement_date >= 365 | is.na(last_achievement_date),
        "Churned",
        "Active"
      )
    )
  
  return(df)
}




















