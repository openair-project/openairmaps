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
#' @seealso [trajLevelMapStatic()] for the static `ggplot2` equivalent of
#'   [trajLevelMap()]
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
    # start map
    map <- leaflet::leaflet()

    # set provider tiles
    for (i in seq_along(unique(provider))) {
      map <- leaflet::addProviderTiles(
        map,
        provider = unique(provider)[[i]],
        group = unique(provider)[[i]]
      )
    }

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

    # control menu - "type" levels are the base groups if present, otherwise
    # the providers are
    provider <- unique(provider)
    if (length(provider) > 1 || !is.null(type)) {
      base_groups <- provider
      overlay_groups <- character(0)
      if (!is.null(type)) {
        # (suppress warnings already given by addTrajLevel())
        type_levels <- suppressWarnings(openair::cutData(data, type = type))
        base_groups <- as.character(sort(unique(type_levels[[type]])))
        if (length(provider) > 1) {
          overlay_groups <- provider
        }
      }

      map <-
        leaflet::addLayersControl(
          map,
          baseGroups = base_groups,
          overlayGroups = overlay_groups,
          position = control.position,
          options = leaflet::layersControlOptions(collapsed = control.collapsed)
        )
    }

    # return map
    return(map)
  }
