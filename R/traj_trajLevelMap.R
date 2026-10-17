#' Trajectory level plots in `leaflet`
#'
#' This function plots back trajectories on a `leaflet` map. This function
#' requires that data are imported using the [openair::importTraj()] function.
#'
#' @family interactive trajectory maps
#' @inheritParams trajMap
#' @inheritParams addTrajLevel
#'
#' @returns A leaflet object.
#' @export
#'
#' @seealso [openair::trajLevel()]
#' @seealso [addTrajLevel()] to add gridded trajectory statistics to any
#'   leaflet map
#'
#' @examples
#' \dontrun{
#' trajLevelMap(traj_data, pollutant = "pm2.5", statistic = "pscf", min.bin = 10)
#' }
#'
trajLevelMap <-
  function(
    data,
    longitude = "lon",
    latitude = "lat",
    pollutant,
    type = NULL,
    smooth = FALSE,
    statistic = "frequency",
    percentile = 90,
    lon.inc = 1,
    lat.inc = 1,
    breaks = NULL,
    min.bin = 1,
    .combine = NULL,
    sigma = 1.5,
    cols = "turbo",
    alpha = 0.5,
    tile.border = NA,
    provider = "OpenStreetMap",
    legend.position = "topright",
    legend.title = NULL,
    legend.title.autotext = TRUE,
    control.collapsed = FALSE,
    control.position = "topright"
  ) {
    # check basemap providers are valid
    provider <- check_providers(provider, static = FALSE)

    # start map
    map <- leaflet::leaflet() |>
      add_basemaps(provider)

    # add gridded trajectory statistics
    map <- addTrajLevel(
      map,
      data = data,
      lng = longitude,
      lat = latitude,
      pollutant = if (missing(pollutant)) NULL else pollutant,
      statistic = statistic,
      percentile = percentile,
      lon.inc = lon.inc,
      lat.inc = lat.inc,
      breaks = breaks,
      min.bin = min.bin,
      .combine = .combine,
      sigma = sigma,
      smooth = smooth,
      type = type,
      cols = cols,
      alpha = alpha,
      tile.border = tile.border,
      legend.position = legend.position,
      legend.title = legend.title,
      legend.title.autotext = legend.title.autotext
    )

    # control menu - "type" levels (if any) are the base groups
    type_levels <- NULL
    if (!is.null(type)) {
      # (suppress warnings already given by addTrajLevel())
      type_levels <- suppressWarnings(openair::cutData(data, type = type))
      type_levels <- sort(unique(type_levels[[type]]))
    }

    map <- add_layer_control(
      map,
      provider = provider,
      groups = type_levels,
      position = control.position,
      collapsed = control.collapsed
    )

    # return map
    return(map)
  }
