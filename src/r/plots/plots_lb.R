

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


plot_lb_range_interactive <- function(df, column, start, end, bin_width, scalexby) {
  # Create the HTML code
  html <- sprintf('
    <html>
    <head>
      <title>Interactive Histogram</title>
      <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    </head>
    <body>
      <div id="plot"></div>
      <div>
        <label for="start">Start:</label>
        <input type="number" id="start" value="%d" step="1">
      </div>
      <div>
        <label for="end">End:</label>
        <input type="number" id="end" value="%d" step="1">
      </div>
      <div>
        <label for="bin_width">Bin Width:</label>
        <input type="number" id="bin_width" value="%d" step="1">
      </div>
      <div>
        <label for="scalexby">Scale X by:</label>
        <input type="number" id="scalexby" value="%d" step="1">
      </div>
      <script>
        var data = %s;
        var plotDiv = document.getElementById("plot");
        var startInput = document.getElementById("start");
        var endInput = document.getElementById("end");
        var binWidthInput = document.getElementById("bin_width");
        var scalexbyInput = document.getElementById("scalexby");
        
        function updatePlot() {
          var start = parseInt(startInput.value);
          var end = parseInt(endInput.value);
          var binWidth = parseInt(binWidthInput.value);
          var scalexby = parseInt(scalexbyInput.value);
          
          var filteredData = data.filter(function(d) {
            return d >= start && d <= end;
          });
          
          var trace = {
            x: filteredData,
            type: "histogram",
            marker: { color: "blue" }
          };
          
          var layout = {
            title: "Distribution of %s (" + start + " to " + end + ")",
            xaxis: { title: "%s", range: [start, end], dtick: scalexby },
            yaxis: { title: "Frequency" },
            bargap: 0.1,
            bargroupgap: 0.2
          };
          
          Plotly.newPlot(plotDiv, [trace], layout);
        }
        
        updatePlot();
        
        startInput.addEventListener("input", updatePlot);
        endInput.addEventListener("input", updatePlot);
        binWidthInput.addEventListener("input", updatePlot);
        scalexbyInput.addEventListener("input", updatePlot);
      </script>
    </body>
    </html>
  ', start, end, bin_width, scalexby, jsonlite::toJSON(df[[column]]), column, column)
  
  # Save the HTML code to a file
  writeLines(html, con = "lb_plot.html")
  # Display the plot within the RMD cell
  includeHTML("lb_plot.html")
}









