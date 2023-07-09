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


plot_lb_range_interactive <- function(df, column, start, end, scalexby) {
  # Create the HTML code
  html <- sprintf('
    <html>
    
    <head>
      <title>Leaderboard Interactive Histogram</title>
      <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
      <style>
        body {
          font-family: Arial, sans-serif;
          font-size: 14px;
          line-height: 1.5;
          margin: 20px;
        }
        
        h1 {
          font-size: 20px;
          margin-bottom: 10px;
        }
        
        label {
          display: block;
          margin-bottom: 5px;
        }
        
        input[type="number"] {
          width: 150px;
          padding: 5px;
          font-size: 14px;
        }
        
        #plot {
          margin-top: 20px;
        }
        
        /* Modified CSS for axis labels */
        .xtitle, .ytitle {
          font-family: Arial, sans-serif;
          font-size: 16px;
          font-weight: bold;
        }
        
        .xticktext, .yticktext {
          font-family: Arial, sans-serif;
          font-size: 12px;
        }
      </style>
    </head>
    
    <body>
      <h1>Leaderboard Interactive Histogram</h1>
      
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
        <label for="scalexby">Scale X by:</label>
        <input type="number" id="scalexby" value="%d" step="1">
      </div>
      
      <script>
        var data = %s;
        var plotDiv = document.getElementById("plot");
        var startInput = document.getElementById("start");
        var endInput = document.getElementById("end");
        
        var scalexbyInput = document.getElementById("scalexby");
        
        function updatePlot() {
          var start = parseInt(startInput.value);
          var end = parseInt(endInput.value);
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
        scalexbyInput.addEventListener("input", updatePlot);
        
      </script>
    </body>
    </html>
  ', start, end, scalexby, jsonlite::toJSON(df[[column]]), column, column)
  
  # Save the HTML code to a file
  writeLines(html, con = "./src/html/lb_plot.html")
  # Display the plot within the RMD cell
  includeHTML("./src/html/lb_plot.html")
}




