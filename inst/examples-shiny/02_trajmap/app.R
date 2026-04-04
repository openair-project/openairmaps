traj_data <- openairmaps::traj_data
dates <- unique(traj_data$date)

map <- leaflet::leaflet() |>
  leaflet::addProviderTiles(provider = leaflet::providers$CartoDB.Voyager) |>
  leaflet::setView(lng = -10, lat = 60, zoom = 4)

ui <- bslib::page_fillable(
  theme = bslib::bs_theme(preset = "flatly", primary = "#2c7bb6"),
  title = "Trajectory Explorer",
  shiny::useBusyIndicators(),
  bslib::card(
    full_screen = TRUE,
    bslib::card_header(
      class = "d-flex align-items-center gap-2",
      shiny::icon("wind"),
      "Trajectory Explorer"
    ),
    bslib::card_body(
      padding = 0,
      leaflet::leafletOutput("map", height = "100%")
    ),
    bslib::card_footer(
      shiny::div(
        class = "d-flex align-items-center gap-3",
        shiny::div(
          style = "white-space: nowrap; font-size: 0.8rem; color: #666;",
          shiny::icon("calendar-days"),
          shiny::strong("Arrival dates")
        ),
        shiny::div(
          style = "flex-grow: 1;",
          shiny::sliderInput(
            timezone = "+0000",
            width = "100%",
            timeFormat = "%b %Y",
            "slider",
            label = NULL,
            min = min(dates),
            max = max(dates),
            value = range(dates)
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet(map)

  observeEvent(input$slider, {
    leaflet::leafletProxy("map") |>
      leaflet::clearGroup("trajpaths")

    thedates <- dates[dates >= min(input$slider) & dates <= max(input$slider)]
    thedata <- traj_data[traj_data$date %in% thedates, ]

    leaflet::leafletProxy("map") |>
      openairmaps::addTrajPaths(
        layerId = "traj",
        data = thedata,
        group = "trajpaths"
      )
  })
}

shiny::shinyApp(ui, server)
