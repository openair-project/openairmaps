#' Add polar markers to leaflet map
#'
#' This function is similar (but not identical to) the [leaflet::addMarkers()]
#' and [leaflet::addCircleMarkers()] functions in `leaflet`, which allows users
#' to add `openair` directional analysis plots to any leaflet map and have more
#' control over groups and layerIds than in "all-in-one" functions like
#' [polarMap()].
#'
#' @inheritParams leaflet::addMarkers
#' @order 1
#' @param data A data frame. The data frame must contain the data to plot your
#'   choice of openair directional analysis plot, which includes wind speed
#'   (`ws`), wind direction (`wd`), and the column representing the
#'   concentration of a pollutant. In addition, `data` must include a decimal
#'   latitude and longitude. By default, it is the data object provided to
#'   [leaflet::leaflet()] initially, but can be overridden.
#' @param pollutant The name of the pollutant to be plot. Note that, if `fun =
#'   openair::windRose`, you must set `pollutant = "ws"`.
#' @param fun An `openair` directional analysis plotting function. Supported
#'   functions include [openair::polarPlot()] (the default),
#'   [openair::polarAnnulus()], [openair::polarFreq()],
#'   [openair::percentileRose()], [openair::pollutionRose()] and
#'   [openair::windRose()]. For [openair::polarDiff()], use
#'   [addPolarDiffMarkers()].
#' @param lng The decimal longitude.
#' @param lat The decimal latitude.
#' @param popup A column of `data` to be used as a popup.
#' @param label A column of `data` to be used as a label.
#' @param key.position Passed to `key.position` for the relevant `fun`.
#' @param d.icon The diameter of the plot on the map in pixels. This will affect
#'   the size of the individual polar markers. Alternatively, a vector in the
#'   form `c(width, height)` can be provided if a non-circular marker is
#'   desired.
#' @param d.fig The diameter of the plots to be produced using `openair` in
#'   inches. This will affect the resolution of the markers on the map.
#'   Alternatively, a vector in the form `c(width, height)` can be provided if a
#'   non-circular marker is desired.
#' @param alpha The desired opacity of the polar markers. Can also be set via
#'   `options` but is provided here for convenience.
#' @param progress Show a progress bar while the markers are created?
#' @param ... Other arguments for the plotting function (e.g. `period` for
#'   [openair::polarAnnulus()]).
#' @returns A leaflet object.
#' @seealso `shiny::runExample(package = "openairmaps")` to see examples of this
#'   function used in a [shiny::shinyApp()]
#' @describeIn addPolarMarkers Add any one-table polar marker (e.g.,
#'   [openair::polarPlot()])
#' @export
#'
#' @examples
#' \dontrun{
#' library(leaflet)
#' library(openair)
#'
#' # different types of polar plot on one map
#' leaflet(data = polar_data) |>
#'   addTiles() |>
#'   addPolarMarkers(
#'     "ws",
#'     fun = openair::windRose,
#'     annotate = FALSE,
#'     group = "Wind Rose"
#'   ) |>
#'   addPolarMarkers("nox", fun = openair::polarPlot, group = "Polar Plot") |>
#'   addLayersControl(
#'     baseGroups = c("Wind Rose", "Polar Plot")
#'   )
#'
#' # use of polar diff (NB: both 'before' and 'after' inherit from `leaflet()`,
#' # so at least one should be overridden - in this case 'after')
#' leaflet(data = polar_data) |>
#'   addTiles() |>
#'   addPolarDiffMarkers("nox",
#'     after = dplyr::mutate(polar_data, nox = jitter(nox, 5))
#'   )
#' }
addPolarMarkers <-
  function(
    map,
    pollutant,
    fun = openair::polarPlot,
    lng = NULL,
    lat = NULL,
    layerId = NULL,
    group = NULL,
    popup = NULL,
    popupOptions = NULL,
    label = NULL,
    labelOptions = NULL,
    options = leaflet::markerOptions(),
    clusterOptions = NULL,
    clusterId = NULL,
    key.position = "none",
    d.icon = 200,
    d.fig = 3.5,
    alpha = 1,
    progress = TRUE,
    data = leaflet::getMapData(map),
    ...
  ) {
    add_polar_markers(fun = fun, data = data, ...)
  }

#' @inheritParams diffMap
#' @param before,after A data frame that represents the before/after case. See
#'   [openair::polarPlot()] for details of different input requirements. By
#'   default, both `before` and `after` are the data object provided to
#'   [leaflet::leaflet()] initially, but at least one should be overridden.
#' @describeIn addPolarMarkers Add the two-table [openair::polarDiff()] marker.
#' @order 2
#' @export
addPolarDiffMarkers <-
  function(
    map,
    pollutant,
    before = leaflet::getMapData(map),
    after = leaflet::getMapData(map),
    lng = NULL,
    lat = NULL,
    layerId = NULL,
    group = NULL,
    popup = NULL,
    popupOptions = NULL,
    label = NULL,
    labelOptions = NULL,
    options = leaflet::markerOptions(),
    clusterOptions = NULL,
    clusterId = NULL,
    key.position = "none",
    d.icon = 200,
    d.fig = 3.5,
    alpha = 1,
    progress = TRUE,
    ...
  ) {
    add_polar_markers(
      fun = openair::polarDiff,
      data = before,
      after = after,
      ...
    )
  }

#' Arguments shared by `addPolarMarkers()` and `addPolarDiffMarkers()`
#'
#' `add_polar_markers()` reads these from the calling function, so they don't
#' have to be passed through by hand. Both functions must have all of them as
#' arguments - see `test-addPolarMarkers.R`.
#' @noRd
polar_marker_args <- c(
  "map",
  "pollutant",
  "lng",
  "lat",
  "layerId",
  "group",
  "popup",
  "popupOptions",
  "label",
  "labelOptions",
  "options",
  "clusterOptions",
  "clusterId",
  "key.position",
  "d.icon",
  "d.fig",
  "alpha",
  "progress"
)

#' Add polar markers to a leaflet map
#'
#' The shared implementation of `addPolarMarkers()` and `addPolarDiffMarkers()`.
#' Collects the shared arguments (see `polar_marker_args`) from the calling
#' function, plots one marker per location, and attaches them to the map.
#' @param fun,data,after As in `create_polar_markers()`. `data` also provides
#'   any popups/labels.
#' @param ... The `...` of the calling function, passed to `fun`.
#' @param env The calling function's environment.
#' @noRd
add_polar_markers <- function(
  fun,
  data,
  after = NULL,
  ...,
  env = rlang::caller_env()
) {
  args <- rlang::env_get_list(env, polar_marker_args)

  # guess lat/lon
  latlon <- assume_latlon(
    data = data,
    latitude = args$lat,
    longitude = args$lng
  )

  # one marker per location, so use a dummy split_col
  data$dummyvar <- "dummyvar"
  if (!is.null(after)) {
    after$dummyvar <- "dummyvar"
  }

  # plot and save static markers
  plots_df <-
    create_polar_markers(
      fun = fun,
      fun_args = c(
        list(
          pollutant = args$pollutant,
          key.position = args$key.position,
          plot = FALSE
        ),
        rlang::list2(...)
      ),
      data = data,
      after = after,
      latitude = latlon$latitude,
      longitude = latlon$longitude,
      split_col = "dummyvar",
      d.fig = args$d.fig,
      popup = args$popup,
      label = args$label,
      dropcol = args$pollutant,
      progress = args$progress
    )

  # add markers to map
  rlang::exec(
    attach_marker_icons,
    map = args$map,
    data = plots_df,
    latitude = latlon$latitude,
    longitude = latlon$longitude,
    !!!args[setdiff(
      polar_marker_args,
      c(
        "map",
        "pollutant",
        "lng",
        "lat",
        "key.position",
        "d.fig",
        "progress"
      )
    )]
  )
}
