#' Add gridded trajectory statistics to leaflet map
#'
#' This function is similar (but not identical to) the [leaflet::addRectangles()]
#' function in `leaflet`, which allows users to add gridded trajectory
#' statistics (calculated using [openair::trajLevel()]) to any leaflet map and
#' have more control over groups and layerIds than in "all-in-one" functions
#' like [trajLevelMap()].
#'
#' @inheritParams addTrajPaths
#' @inheritParams openair::trajLevel
#' @param pollutant The pollutant of interest. Not required when `statistic =
#'   "frequency"`.
#' @param type Optionally, a method to condition the `data`, passed to
#'   [openair::cutData()]. Each level of `type` is added to the map as its own
#'   `group` (sharing a single colour scale), so can be toggled between using
#'   [leaflet::addLayersControl()]. If `type` is provided, `group` is ignored.
#' @param smooth Should the trajectory surface be smoothed? Defaults to `FALSE`.
#'   Note that, when `smooth = TRUE`, no popup information will be available.
#' @param cols The colours used for plotting, passed to
#'   [openair::openColours()]. The default, `"turbo"`, is a rainbow palette with
#'   relatively perceptually uniform colours.
#' @param alpha Opacity of the tiles. Must be between `0` and `1`.
#' @param tile.border Colour to use for the border of binned tiles. Defaults to
#'   `NA`, which draws no border.
#' @param layerId The base string for the layer id. The actual layer IDs will be
#'   in the format "layerId-tilenum". For example, the first tile will be
#'   "layerId-1".
#' @param legend Should a legend be added to the map? Defaults to `TRUE`. When
#'   `type` is not used, the legend is given the same `group` as the tiles, so
#'   it is shown and hidden alongside them.
#' @param legend.position Where should the legend be placed? One of "topright",
#'   "topleft", "bottomleft" or "bottomright". Passed to the `position`
#'   argument of [leaflet::addLegend()].
#' @param legend.title Title of the legend. By default, when `legend.title =
#'   NULL`, the function will attempt to provide a sensible legend title based
#'   on `statistic`. `legend.title` allows users to overwrite this - for
#'   example, to include units or other contextual information. Users may wish
#'   to use HTML tags to format the title.
#' @param legend.title.autotext When `legend.title.autotext = TRUE`,
#'   `legend.title` will be first run through [quickTextHTML()].
#' @param ... Other arguments to pass to [leaflet::addRectangles()]. These will
#'   override any defaults set by [addTrajLevel()] (e.g., `weight`).
#' @returns A leaflet object.
#' @seealso [openair::trajLevel()]
#' @export
#'
#' @examples
#' \dontrun{
#' library(leaflet)
#'
#' leaflet() |>
#'   addTiles() |>
#'   addTrajLevel(
#'     data = traj_data,
#'     pollutant = "pm2.5",
#'     statistic = "pscf",
#'     min.bin = 10,
#'     group = "PSCF"
#'   ) |>
#'   addLayersControl(overlayGroups = "PSCF")
#' }
addTrajLevel <-
  function(
    map,
    data = leaflet::getMapData(map),
    lng = "lon",
    lat = "lat",
    pollutant = NULL,
    statistic = "frequency",
    percentile = 90,
    lon.inc = 1,
    lat.inc = 1,
    breaks = NULL,
    min.bin = 1,
    .combine = NULL,
    sigma = 1.5,
    smooth = FALSE,
    type = NULL,
    cols = "turbo",
    alpha = 0.5,
    tile.border = NA,
    layerId = NULL,
    group = NULL,
    legend = TRUE,
    legend.position = "topright",
    legend.title = NULL,
    legend.title.autotext = TRUE,
    ...
  ) {
    # get titles/legend styles (and a shorter description for the popups)
    style <- leaflet::labelFormat()
    title <- ""
    subtitle <- toupper(statistic)
    if (statistic == "frequency") {
      title <- "percentage<br>trajectories"
      subtitle <- "% OF TRAJECTORIES"
      style <- leaflet::labelFormat(between = " to ", suffix = "%")
      pollutant <- "default_pollutant"
      data[[pollutant]] <- pollutant
    } else if (is.null(pollutant)) {
      cli::cli_abort(
        "{.arg pollutant} must be provided when {.arg statistic} is {.val {statistic}}."
      )
    }
    if (statistic == "difference") {
      pct <- ordinal(percentile)
      title <- paste0("gridded<br>differences<br>(", pct, " percentile)")
      subtitle <- paste0("% DIFFERENCE (", toupper(pct), " PERCENTILE)")
      style <- leaflet::labelFormat(between = " to ", suffix = "%")
    }
    if (statistic == "pscf") {
      title <- "PSCF<br>probability"
      subtitle <- "PSCF PROBABILITY"
    }
    if (statistic == "sqtba") {
      title <- stringr::str_glue("SQTBA<br>{pollutant}")
    }
    if (statistic %in% c("cwt", "sqtba")) {
      subtitle <- paste(toupper(statistic), "&middot;", toupper(pollutant))
    }

    legend.title <- create_legend_title(
      static = FALSE,
      legend.title.autotext = legend.title.autotext,
      legend.title = legend.title,
      str = title
    )

    # openair::trajLevel() needs columns named "lat" and "lon", whatever its
    # `lat`/`lon` arguments are
    names(data)[names(data) == lng] <- "lon"
    names(data)[names(data) == lat] <- "lat"

    # calculate gridded statistics - only pass `breaks` if given, as
    # trajLevel() uses `missing(breaks)` to decide on its default breaks
    traj_args <- list(
      mydata = data,
      lon = "lon",
      lat = "lat",
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
    )
    if (!is.null(breaks)) {
      traj_args$breaks <- breaks
    }
    data <- rlang::exec(openair::trajLevel, !!!traj_args)$data

    # smoothing changes the grid resolution, so work it out again
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
          n = nlevels(data[[pollutant]])
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

    popup <- NA
    if (!smooth) {
      popup <- build_traj_level_labels(
        data,
        subtitle = quickTextHTML(subtitle),
        type = type
      )
    }

    # "type" levels become groups
    if (!is.null(type)) {
      group <- data[[type]]
    }

    if (!is.null(layerId)) {
      layerId <- paste(layerId, seq_len(nrow(data)), sep = "-")
    }

    # make map - users can override any of these defaults via `...`
    rect_args <- utils::modifyList(
      list(
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
        group = group,
        layerId = layerId
      ),
      list(...)
    )
    map <- rlang::exec(leaflet::addRectangles, !!!rect_args)

    if (legend) {
      # a shared legend across "type" can't belong to any one group
      legend_group <- if (is.null(type)) group else NULL

      if (is.factor(data[[pollutant]])) {
        map <- leaflet::addLegend(
          map,
          title = legend.title,
          opacity = alpha,
          position = legend.position,
          colors = pal(rev(levels(data[[pollutant]]))),
          labels = rev(levels(data[[pollutant]])),
          labFormat = style,
          values = NULL,
          group = legend_group
        )
      } else {
        map <- leaflet::addLegend(
          map,
          title = legend.title,
          opacity = alpha,
          position = legend.position,
          pal = pal,
          values = data[[pollutant]],
          labFormat = style,
          group = legend_group
        )
      }
    }

    map
  }
