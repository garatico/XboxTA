# Define a vector of consistent colors for the months
month_colors <- c(
  Jan = "#FF0000",   # Red
  Feb = "#FF69B4",   # Pink
  Mar = "#00FF00",   # Green
  Apr = "#FFFF00",   # Yellow
  May = "#0000FF",   # Blue
  Jun = "#8A2BE2",   # Blue Violet
  Jul = "#FF7F00",   # Orange
  Aug = "#008080",   # Teal
  Sep = "#FF1493",   # Deep Pink
  Oct = "#7FFF00",   # Chartreuse
  Nov = "#800000",   # Maroon
  Dec = "#800080",   # Purple
  "NA" = "#A9A9A9"   # Dark Gray
)

plot_gamer_achievement_freq_year <- function(df) {
  df$year <- as.factor(df$year)  # Convert year column to a factor
  
  # Plot for Year
  plot_year <- ggplot(df, aes(x = year, y = n, fill = year)) +
    geom_bar(stat = "identity") +
    labs(title = "Frequency of Achievements by Year",
         x = "Year",
         y = "Frequency") +
    scale_fill_discrete(labels = function(x) format(as.integer(x))) +  # Remove decimal places in legend
    theme_minimal()
  
  return(plot_year)
}


plot_gamer_achievement_freq_month <- function(df) {
  # Convert month column to a factor with desired order and NA as last
  df$month <- factor(df$month, levels = 1:12, labels = month.abb)
  
  # Plot for Month
  plot_month <- ggplot(df, aes(x = month, y = n, fill = month)) +
    geom_bar(stat = "identity") +
    labs(title = "Frequency of Achievements by Month",
         x = "Month",
         y = "Frequency") +
    scale_fill_manual(values = month_colors) +
    theme_minimal()
  
  return(plot_month)
}

plot_gamer_achievement_freq_month_year <- function(df) {
  df <- data.frame(df)  # Convert the input list to a data frame
  
  # Replace NA values in month and year columns with a custom label
  df$month <- ifelse(is.na(df$month), "NA", as.character(df$month))
  df$year <- ifelse(is.na(df$year), "NA", as.character(df$year))
  
  # Convert month column to a factor with desired order and NA as last
  df$month <- factor(df$month, levels = 1:12, labels = month.abb)
  
  # Plot for Month and Year
  plot_month_year <- ggplot(df, aes(x = year, y = n, fill = month)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(title = "Frequency of Achievements by Month and Year",
         x = "Year",
         y = "Frequency") +
    scale_fill_manual(values = month_colors) +
    theme_minimal()
  
  return(plot_month_year)
}

plot_gamer_achievement_freq_week <- function(df) {
  # Plot for Week
  plot_week <- ggplot(df, aes(x = week, y = n, fill = week)) +
    geom_bar(stat = "identity") +
    labs(title = "Frequency of Achievements by Week",
         x = "Week",
         y = "Frequency") +
    theme_minimal()
  
  return(plot_week)
}

plot_gamer_achievement_freq_weekday <- function(df) {
  # Plot for Weekend
  plot_weekday <- ggplot(df, aes(x = weekday, y = n, fill = weekday)) +
    geom_bar(stat = "identity") +
    labs(title = "Frequency of Achievements by Weekday",
         x = "Weekday",
         y = "Frequency") +
    theme_minimal()
  
  return(plot_weekday)
}







