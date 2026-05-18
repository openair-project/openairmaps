#' Trajectory level plots in `leaflet`
#'
#' This function plots back trajectories on a `leaflet` map. This function
#' requires that data are imported using the [openair::importTraj()] function.
#'
#' @family interactive trajectory maps
#' @inheritParams trajMap
#' @inheritParams openair::trajLevel
#' @param cols The colours used for plotting, passed to
#'   [openair::openColours()]. The default, `"turbo"`, is a rainbow palette with
#'   relatively perceptually uniform colours.
#' @param alpha Opacity of the tiles. Must be between `0` and `1`.
#' @param tile.border Colour to use for the border of binned tiles. Defaults to
#'   `NA`, which draws no border.
#' @param smooth Should the trajectory surface be smoothed? Defaults to `FALSE`.
#'   Note that, when `smooth = TRUE`, no popup information will be available.
#'
#' @returns A leaflet object.
#' @export
#'
#' @seealso [openair::trajLevel()]
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
    # get titles/legend styles

    style <- leaflet::labelFormat()
    if (statistic == "frequency") {
      title <- "percentage<br>trajectories"
      style <- leaflet::labelFormat(between = " to ", suffix = "%")
      pollutant <- "default_pollutant"
      data[[pollutant]] <- pollutant
    }
    if (statistic == "difference") {
      lastnum <- stringr::str_sub(percentile, 2, 2)
      suff <- "th"
      if (lastnum == "1") {
        suff <- "st"
      }
      if (lastnum == "2") {
        suff <- "nd"
      }
      if (lastnum == "3") {
        suff <- "rd"
      }
      title <-
        stringr::str_glue(
          "gridded<br>differences<br>({percentile}{suff} percentile)"
        )
      style <- leaflet::labelFormat(between = " to ", suffix = "%")
    }

    if (statistic == "pscf") {
      title <- "PSCF<br>probability"
    }
    if (statistic == "cwt") {
      title <- ""
    }
    if (statistic == "sqtba") {
      title <- stringr::str_glue("SQTBA<br>{pollutant}")
    }

    legend.title <- legend.title %||% title
    if (legend.title.autotext) {
      legend.title <- quickTextHTML(legend.title)
    }

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

    if (missing(breaks)) {
      data <- openair::trajLevel(
        mydata = data,
        lon = longitude,
        lat = latitude,
        pollutant = pollutant,
        statistic = statistic,
        percentile = percentile,
        lat.inc = lat.inc,
        lon.inc = lon.inc,
        min.bin = min.bin,
        .combine = .combine,
        sigma = sigma,
        type = type %||% "default",
        smooth = smooth,
        plot = FALSE
      )$data
    } else {
      data <- openair::trajLevel(
        mydata = data,
        lon = longitude,
        lat = latitude,
        pollutant = pollutant,
        statistic = statistic,
        percentile = percentile,
        lat.inc = lat.inc,
        lon.inc = lon.inc,
        breaks = breaks,
        min.bin = min.bin,
        .combine = .combine,
        sigma = sigma,
        type = type %||% "default",
        smooth = smooth,
        plot = FALSE
      )$data
    }

    # smooth
    if (smooth) {
      xtest <- dplyr::filter(data, .data$ygrid == .data$ygrid[[1]]) |>
        dplyr::arrange(.data$xgrid)
      xtest <- xtest$xgrid - dplyr::lag(xtest$xgrid)
      lon.inc <- unique(xtest[!is.na(xtest)])[[1]]

      ytest <- dplyr::filter(data, .data$xgrid == .data$xgrid[[1]]) |>
        dplyr::arrange(.data$ygrid)
      ytest <- ytest$ygrid - dplyr::lag(ytest$ygrid)
      lat.inc <- unique(ytest[!is.na(ytest)])[[1]]
    }

    names(data)[names(data) == "height"] <- pollutant

    if (is.factor(data[[pollutant]])) {
      pal <- leaflet::colorFactor(
        palette = openair::openColors(
          scheme = cols,
          n = length(levels(data[[pollutant]]))
        ),
        domain = factor(unique(data[[pollutant]]), levels(data[[pollutant]]))
      )
    } else {
      pal <-
        leaflet::colorNumeric(
          palette = openair::openColours(scheme = cols),
          domain = data[[pollutant]]
        )
    }

    # each statistic outputs a different name for "count"
    data$val <- data[[pollutant]]
    data$gridcount <- NA
    if ("count" %in% names(data)) {
      data$gridcount <- data$count
    }

    # make hover label & popups
    data$label <- data$val
    if (is.numeric(data$label)) {
      data$label <- signif(data$label, 3)
    }

    # create label
    if (!smooth) {
      data <- dplyr::mutate(
        data,
        popup = stringr::str_glue(
          "<b>Lat:</b> {ygrid} | <b>Lon:</b> {xgrid}<br>
          <b>Count:</b> {gridcount}<br>
          <b>Value:</b> {label}"
        ),
        coord = stringr::str_glue("({ygrid}, {xgrid})")
      )
      popup <- data$popup
    } else {
      popup <- NA
    }

    # make map
    map <-
      leaflet::addRectangles(
        map = map,
        data = data,
        lng1 = data[["xgrid"]] - (lon.inc / 2),
        lng2 = data[["xgrid"]] + (lon.inc / 2),
        lat1 = data[["ygrid"]] - (lat.inc / 2),
        lat2 = data[["ygrid"]] + (lat.inc / 2),
        color = tile.border,
        weight = 1,
        fillOpacity = alpha,
        fillColor = pal(data[[pollutant]]),
        popup = popup,
        label = data[["label"]],
        group = data[[type %||% "default"]]
      )

    if (is.factor(data[[pollutant]])) {
      map <- leaflet::addLegend(
        map,
        title = legend.title,
        position = legend.position,
        colors = pal(rev(levels(data[[pollutant]]))),
        labels = rev(levels(data[[pollutant]])),
        labFormat = style,
        values = NULL
      )
    } else {
      map <- leaflet::addLegend(
        map,
        title = legend.title,
        position = legend.position,
        pal = pal,
        values = data[[pollutant]],
        labFormat = style
      )
    }

    # control menu
    if (length(unique(provider)) > 1 && is.null(type)) {
      map <- leaflet::addLayersControl(map, baseGroups = unique(provider))
    } else if (
      length(unique(provider)) == 1 &&
        !is.null(type)
    ) {
      map <-
        leaflet::addLayersControl(map, baseGroups = sort(unique(data[[type]])))
    } else if (
      length(unique(provider)) > 1 &&
        !is.null(type)
    ) {
      map <-
        leaflet::addLayersControl(
          map,
          overlayGroups = unique(provider),
          baseGroups = sort(unique(data[[type]]))
        )
    }

    # return map
    return(map)
  }
