// lb_script.js

/*
var data = [];
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
*/

alert("reached")

document.addEventListener("DOMContentLoaded", function() {
  var data = [/* Your data here */];
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
      title: "Distribution of Column (" + start + " to " + end + ")",
      xaxis: { title: "Column", range: [start, end], dtick: scalexby },
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
});




