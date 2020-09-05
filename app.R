library(shiny)
library(shinyMobile)
library(httr)
colors <- c(
  RColorBrewer::brewer.pal(9,"GnBu")[8:6],
  RColorBrewer::brewer.pal(9,"Greens")[6:8],
  RColorBrewer::brewer.pal(9,"OrRd")[5:7]
)
shiny::shinyApp(
  ui = f7Page(
    title = "Hops Dryer",
    f7SingleLayout(
      navbar = f7Navbar(title = "Hops Dryer"),
      uiOutput("visuals")
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
              color=colors[round(result()$field2/10)],
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
