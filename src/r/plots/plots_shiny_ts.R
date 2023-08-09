generate_ts_shiny_plots = function(ts_profiles) {
  # Define UI
  ui <- fluidPage(
    titlePanel("Time Series Decomposition Plots"),
    sidebarLayout(
      sidebarPanel(
        selectInput("profile", "Select Profile:", choices = seq_along(ts_profiles), selected = ts_profiles[[1]], width = "25%")
      ),
      mainPanel(
        plotOutput("plot1"),
        plotOutput("plot2"),
        plotOutput("plot3"),
        plotOutput("plot4")
      )
    )
  )
  
  # Define server
  server <- function(input, output) {
    output$plot1 <- renderPlot({
      profile <- ts_profiles[[as.numeric(input$profile)]]
      plot_data <- data.frame(
        date = time(profile$ts[[1]]),
        stringsAsFactors = FALSE
      )
      plot_data$original1 <- profile$ts[[1]]
      plot_data$trend1 <- profile$decomposition[[1]][["trend"]]
      plot_data$seasonal1 <- profile$decomposition[[1]][["seasonal"]]
      plot_data$residual1 <- profile$decomposition[[1]][["random"]]
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = original1, color = "Original")) +
        geom_line(aes(y = trend1, color = "Trend")) +
        geom_line(aes(y = seasonal1, color = "Seasonal")) +
        geom_line(aes(y = residual1, color = "Residual")) +
        labs(x = "Date", y = "Value", color = "Component") +
        scale_color_manual(values = c("Original" = "black", "Trend" = "blue",
                                      "Seasonal" = "red", "Residual" = "green")) +
        facet_wrap(~ "Time Series 1: Daily Lifetime EIR", ncol = 1) +
        theme_minimal()
    })
    
    output$plot2 <- renderPlot({
      profile <- ts_profiles[[as.numeric(input$profile)]]
      plot_data <- data.frame(
        date = time(profile$ts[[2]]),
        stringsAsFactors = FALSE
      )
      plot_data$original2 <- profile$ts[[2]]
      plot_data$trend2 <- profile$decomposition[[2]][["trend"]]
      plot_data$seasonal2 <- profile$decomposition[[2]][["seasonal"]]
      plot_data$residual2 <- profile$decomposition[[2]][["random"]]
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = original2, color = "Original")) +
        geom_line(aes(y = trend2, color = "Trend")) +
        geom_line(aes(y = seasonal2, color = "Seasonal")) +
        geom_line(aes(y = residual2, color = "Residual")) +
        labs(x = "Date", y = "Value", color = "Component") +
        scale_color_manual(values = c("Original" = "black", "Trend" = "blue",
                                      "Seasonal" = "red", "Residual" = "green")) +
        facet_wrap(~ "Time Series 2: Weekly EIR", ncol = 1) +
        theme_minimal()
    })
    
    output$plot3 <- renderPlot({
      profile <- ts_profiles[[as.numeric(input$profile)]]
      plot_data <- data.frame(
        date = time(profile$ts[[3]]),
        stringsAsFactors = FALSE
      )
      plot_data$original3 <- profile$ts[[3]]
      plot_data$trend3 <- profile$decomposition[[3]][["trend"]]
      plot_data$seasonal3 <- profile$decomposition[[3]][["seasonal"]]
      plot_data$residual3 <- profile$decomposition[[3]][["random"]]
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = original3, color = "Original")) +
        geom_line(aes(y = trend3, color = "Trend")) +
        geom_line(aes(y = seasonal3, color = "Seasonal")) +
        geom_line(aes(y = residual3, color = "Residual")) +
        labs(x = "Date", y = "Value", color = "Component") +
        scale_color_manual(values = c("Original" = "black", "Trend" = "blue",
                                      "Seasonal" = "red", "Residual" = "green")) +
        facet_wrap(~ "Time Series 3: Monthly EIR", ncol = 1) +
        theme_minimal()
    })
    
    output$plot4 <- renderPlot({
      profile <- ts_profiles[[as.numeric(input$profile)]]
      plot_data <- data.frame(
        date = time(profile$ts[[4]]),
        stringsAsFactors = FALSE
      )
      plot_data$original4 <- profile$ts[[4]]
      plot_data$trend4 <- profile$decomposition[[4]][["trend"]]
      plot_data$seasonal4 <- profile$decomposition[[4]][["seasonal"]]
      plot_data$residual4 <- profile$decomposition[[4]][["random"]]
      
      ggplot(plot_data, aes(x = date)) +
        geom_line(aes(y = original4, color = "Original")) +
        geom_line(aes(y = trend4, color = "Trend")) +
        geom_line(aes(y = seasonal4, color = "Seasonal")) +
        geom_line(aes(y = residual4, color = "Residual")) +
        labs(x = "Date", y = "Value", color = "Component") +
        scale_color_manual(values = c("Original" = "black", "Trend" = "blue",
                                      "Seasonal" = "red", "Residual" = "green")) +
        facet_wrap(~ "Time Series 4: Days Since Achievement Earned", ncol = 1) +
        theme_minimal()
    })
  }
  
  # Run the Shiny app
  shinyApp(ui = ui, server = server)
}