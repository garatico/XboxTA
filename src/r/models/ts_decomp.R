da_profiles_ts_decomp <- function(da_profiles) {
  ts_profiles <- lapply(seq_along(da_profiles), function(i) {
    # Get the current profile from the list of da_profiles
    profile <- da_profiles[[i]]
    profile <- profile %>% arrange(date)
    
    # Create a list of time series objects for each variable
    ts_objs <- list(
      daily_lt_eir = ts(profile$daily_lt_eir, frequency = 366, start = c(profile$year[1], profile$day_of_year[1])),
      weekly_eir = ts(profile$weekly_eir, frequency = 366, start = c(profile$year[1], profile$week[1])),
      monthly_eir = ts(profile$monthly_eir, frequency = 366, start = c(profile$year[1], profile$month.x[1])),
      days_since_achievement = ts(profile$days_since_achievement, frequency = 366, start = c(profile$year[1], profile$day_of_year[1])),
      churn_binary = ts(profile$churn_binary, frequency = 366, start = c(profile$year[1], profile$day_of_year[1]))
    )
    
    # Decompose each time series object and store the decomposition results
    decompositions <- lapply(ts_objs, function(ts_obj) {
      if (length(ts_obj) >= 2 * 366) {
        decompose_result <- decompose(ts_obj)
        return(decompose_result)
      } else {
        return(NULL)
      }
    })
    
    # Check if all decompositions are NULL (insufficient data for decomposition)
    if (all(sapply(decompositions, is.null))) {
      print(paste("Insufficient data for profile", i, "- skipping decomposition."))
      return(NULL)
    } else {
      # Return a list containing profile data, time series objects, and decomposition results
      return(list(
        profile = profile,
        ts = ts_objs,
        decomposition = decompositions
      ))
    }
  })
  return(ts_profiles)
}
