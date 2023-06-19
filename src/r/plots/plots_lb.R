

plot_lb_range = function(df, column, start, end, bin_width, scalexby) {
  plot <- ggplot(df, aes(x = .data[[column]], fill = ..count..)) +
    geom_histogram(data = df[df[[column]] >= start & df[[column]] <= end, ],
                   binwidth = bin_width, color = "white") +
    labs(title = paste("Distribution of", column, "(", format(start, scientific = FALSE), "to", format(end, scientific = FALSE), ")"),
         subtitle = paste("Bin Width:", bin_width),
         x = column,
         y = "Frequency") +
    scale_x_continuous(breaks = seq(start, end, by = scalexby),
                       labels = function(x) format(x, scientific = FALSE)) +
    theme_minimal()
  
  return(plot)
}



