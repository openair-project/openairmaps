polar_data <- openairmaps::polar_data
sites <- unique(polar_data$site)

map <- leaflet::leaflet() |>
  leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron) |>
  leaflet::setView(lng = -0.213492, lat = 51.49548, zoom = 13)

ui <- bslib::page_sidebar(
  title = "Polar Plot Explorer",
  theme = bslib::bs_theme(
    preset = "flatly",
    primary = "#2c7bb6"
  ),
  useBusyIndicators(),
  sidebar = bslib::sidebar(
    width = 260,
    shiny::tags$p(
      "Visualise air quality polar plots across monitoring sites.",
      style = "font-size: 0.85rem; color: #666; margin-bottom: 1rem;"
    ),
    shiny::selectInput(
      "pollutant",
      "Pollutant",
      choices = c(
        "NOx" = "nox",
        "NO2" = "no2",
        "PM2.5" = "pm2.5",
        "PM10" = "pm10"
      )
    ),
    shiny::selectInput(
      "sites",
      "Monitoring Sites",
      choices = sites,
      selected = sites,
      multiple = TRUE
    ),
    shiny::tags$hr(),
    bslib::input_task_button(
      "button",
      "Update Map",
      icon = shiny::icon("map-location-dot"),
      class = "btn-primary w-100"
    )
  ),
  bslib::card(
    full_screen = TRUE,
    bslib::card_body(
      padding = 0,
      leaflet::leafletOutput("map", height = "100%")
    )
  )
)

server <- function(input, output, session) {
  output$map <- leaflet::renderLeaflet(map)

  observeEvent(input$button, {
    leaflet::leafletProxy("map") |>
      leaflet::clearGroup("polarmarkers")

    for (i in seq_along(input$sites)) {
      thedata <- polar_data[polar_data$site == input$sites[i], ]
      thedata <- tidyr::drop_na(thedata, dplyr::all_of(input$pollutant))

      if (nrow(thedata) > 0) {
        leaflet::leafletProxy("map") |>
          openairmaps::addPolarMarkers(
            data = thedata,
            pollutant = input$pollutant,
            layerId = input$sites[i],
            cols = "turbo",
            lng = "lon",
            lat = "lat",
            group = "polarmarkers"
          )
      }
    }
  })
}

shiny::shinyApp(ui, server)
