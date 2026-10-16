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
    data = leaflet::getMapData(map),
    ...
  ) {
    # rename fun input, as `fun` is redefined below to wrap it. `polar_fun`
    # must be passed to `create_polar_markers()` for carrier crating
    polar_fun <- fun

    # guess lat/lon
    latlon <- assume_latlon(
      data = data,
      latitude = lat,
      longitude = lng
    )
    latitude <- latlon$latitude
    longitude <- latlon$longitude

    # define plotting function
    fun_args <- append(
      list(
        pollutant = pollutant,
        key.position = key.position,
        plot = FALSE
      ),
      rlang::list2(...)
    )
    fun <- function(data) {
      rlang::exec(
        .fn = polar_fun,
        !!!append(
          list(mydata = data),
          fun_args
        )
      )
    }

    # create dummy split_col
    data$dummyvar <- "dummyvar"
    split_col <- "dummyvar"

    # plot and save static markers
    plots_df <-
      create_polar_markers(
        fun = fun,
        fun_args = fun_args,
        data = data,
        latitude = latitude,
        longitude = longitude,
        split_col = split_col,
        d.fig = d.fig,
        popup = popup,
        label = label,
        dropcol = pollutant,
        progress = TRUE,
        polar_fun = polar_fun
      )

    # add markers to map
    out_map <- attach_marker_icons(
      map = map,
      data = plots_df,
      latitude = latitude,
      longitude = longitude,
      d.icon = d.icon,
      group = group,
      layerId = layerId,
      popup = popup,
      popupOptions = popupOptions,
      label = label,
      labelOptions = labelOptions,
      options = options,
      clusterOptions = clusterOptions,
      clusterId = clusterId,
      alpha = alpha
    )

    # return map
    return(out_map)
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
    ...
  ) {
    # guess lat/lon
    latlon <- assume_latlon(
      data = before,
      latitude = lat,
      longitude = lng
    )
    latitude <- latlon$latitude
    longitude <- latlon$longitude

    # define plotting function
    fun_args <- append(
      list(
        pollutant = pollutant,
        key.position = key.position,
        plot = FALSE
      ),
      rlang::list2(...)
    )
    fun <- function(before, after) {
      rlang::exec(
        openair::polarDiff,
        !!!append(
          list(before = before, after = after),
          fun_args
        )
      )
    }

    # create dummy split_col
    before$dummyvar <- "dummyvar"
    after$dummyvar <- "dummyvar"
    split_col <- "dummyvar"

    # plot and save static markers
    plots_df <-
      create_polar_markers(
        fun = fun,
        fun_args = fun_args,
        data = before,
        after = after,
        latitude = latitude,
        longitude = longitude,
        split_col = split_col,
        d.fig = d.fig,
        popup = popup,
        label = label,
        dropcol = pollutant,
        progress = TRUE
      )

    # add markers to map
    map <- attach_marker_icons(
      map = map,
      data = plots_df,
      latitude = latitude,
      longitude = longitude,
      d.icon = d.icon,
      group = group,
      layerId = layerId,
      popup = popup,
      popupOptions = popupOptions,
      label = label,
      labelOptions = labelOptions,
      options = options,
      clusterOptions = clusterOptions,
      clusterId = clusterId,
      alpha = alpha
    )

    # return map
    return(map)
  }
