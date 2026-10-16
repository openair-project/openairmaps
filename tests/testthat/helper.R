# Small datasets ---------------------------------------------------------------

# two sites, ~12 days each - enough for openair to draw quickly
small_polar <- function(n = 300) {
  polar_data |>
    dplyr::filter(
      .data$site %in% c("London Bloomsbury", "London Marylebone Road")
    ) |>
    dplyr::slice_head(n = n, by = "site")
}

# a handful of trajectories
small_traj <- function(n = 6) {
  dates <- unique(traj_data$date)[seq_len(n)]
  dplyr::filter(traj_data, .data$date %in% dates)
}

# Fake openair functions -------------------------------------------------------

# a cheap stand-in for an openair polar plotting function, which errors when
# there isn't enough data (as openair does)
fake_polar_fun <- function(data, after = NULL) {
  if (nrow(data) < 10) {
    stop("Not enough data")
  }
  list(
    plot = ggplot2::ggplot(),
    data = data.frame(z = mean(data$conc, na.rm = TRUE))
  )
}

# polar marker data, with one site that has too little data to be plotted
fake_marker_data <- function() {
  tidyr::crossing(
    site = c("A", "B", "C"),
    i = 1:20
  ) |>
    dplyr::filter(.data$site != "B" | .data$i <= 5) |>
    dplyr::mutate(
      lat = c(A = 51, B = 52, C = 53)[.data$site],
      lon = c(A = -1, B = -2, C = -3)[.data$site],
      grp = paste("Group", .data$site),
      conc = .data$i,
      pollutant_name = factor("nox")
    )
}

# run create_polar_markers() quickly on fake data
fake_markers <- function(data = fake_marker_data(), split_col = "grp", ...) {
  create_polar_markers(
    fun = fake_polar_fun,
    fun_args = list(),
    data = data,
    latitude = "lat",
    longitude = "lon",
    split_col = split_col,
    d.fig = 0.5,
    progress = FALSE,
    ...
  )
}

# Inspecting maps --------------------------------------------------------------

# get all calls of a given leaflet method
leaflet_calls <- function(map, method) {
  Filter(\(x) x$method == method, map$x$calls)
}

# get the groups of the markers in a leaflet map, alongside their latitudes
get_marker_groups <- function(map) {
  calls <- leaflet_calls(map, "addMarkers")
  dplyr::bind_rows(lapply(calls, \(x) {
    data.frame(lat = x$args[[1]], group = as.character(x$args[[5]]))
  }))
}

# the names of all tile providers added to a leaflet map
leaflet_providers <- function(map) {
  vapply(leaflet_calls(map, "addProviderTiles"), \(x) x$args[[1]], "")
}

# the layer control groups of a leaflet map
layer_control <- function(map) {
  call <- leaflet_calls(map, "addLayersControl")
  if (length(call) == 0) {
    return(NULL)
  }
  list(
    base = unlist(call[[1]]$args[[1]]),
    overlay = unlist(call[[1]]$args[[2]])
  )
}

# the legends of a leaflet map
leaflet_legends <- function(map) {
  lapply(leaflet_calls(map, "addLegend"), \(x) x$args[[1]])
}

# quieten noisy functions
quietly <- function(expr) {
  suppressMessages(suppressWarnings(expr))
}
