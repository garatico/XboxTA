da_profiles_ts_decomp = function(da_profiles) {
  ts_profiles = lapply(seq_along(da_profiles), function(i) {
    profile <- da_profiles[[i]]
    profile <- profile %>% arrange(date)
    
    ts_objs <- list(
      ts(profile$daily_lt_eir, frequency = 366, start = c(profile$year[1], profile$day_of_year[1])),
      ts(profile$weekly_eir, frequency = 366, start = c(profile$year[1], profile$week[1])),
      ts(profile$monthly_eir, frequency = 366, start = c(profile$year[1], profile$month.x[1])),
      ts(profile$days_since_achievement, frequency = 366, start = c(profile$year[1], profile$day_of_year[1])),
      ts(profile$churn_binary, frequency = 366, start = c(profile$year[1], profile$day_of_year[1]))
    )
    
    decompositions <- lapply(ts_objs, function(ts_obj) {
      if (length(ts_obj) >= 2 * 366) {
        decompose(ts_obj)
      } else {
        NULL
      }
    })
    
    if (all(sapply(decompositions, is.null))) {
      print(paste("Insufficient data for profile", i, "- skipping decomposition."))
      return(NULL)
    } else {
      return(list(
        profile = profile,
        ts = ts_objs,
        decomposition = decompositions
      ))
    }
  })
  return(ts_profiles)
}
