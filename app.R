library(shiny)
library(shinyMobile)
library(httr)
library(readr)
pick_color <- function(temp){
  colors <- c(
    "blue",
    "green",
    "yellow",
    "red"
  )
  ifelse(
    temp < 35, 
    colors[1],
    ifelse(
      temp < 41,
      colors[2],
      ifelse(
        temp < 50,
        "yellow",
        "red"
      )
    )
  )
}
shiny::shinyApp(
  ui = f7Page(
    title = "Hops Dryer",
    f7SingleLayout(
      navbar = f7Navbar(title = "Hops Dryer"),
      uiOutput("visuals"),
      toolbar = f7Toolbar(
        f7Icon("logo_github"),
        a(href = "https://github.com/benjaminschwetz/hops_app",
          "benjaminschwetz/hops_app"),
        position = "bottom")
    )
  ),
  server = function(input, output) {
    result <- reactiveVal({
      read_key <- readLines("secrets")
      response <- GET(
        url = "https://api.thingspeak.com/channels/1018850/feeds.csv",
        query = list(
          api_key = read_key,
          results = 1
        )
      )
      content(response)
    })
    observeEvent(result, {
      output$visuals <- renderUI({
        tagList(
          f7Card(
            title = "Humidity",
            div(align="center",
                f7Gauge(
                  id = "humidity",
                  type  = "semicircle",
                  value = round(result()$field1),
                  borderColor = "#2196f3",
                  borderWidth = 10,
                  valueFontSize = 41,
                  valueTextColor = "#2196f3",
                )
            )
          ),
          f7Card(
            title= "Temperature",
            f7Button(
              color=pick_color(result()$field2),
              label = paste0(result()$field2, " °C")
            )
          ),
          f7Card(
            title = "Last Update",
            result()$created_at
          )
        )
      })
    })
  }
)
