#' Trajectory line plots in `leaflet`
#'
#' This function plots back trajectories on a `leaflet` map. This function
#' requires that data are imported using the [openair::importTraj()] function.
#' Options are provided to colour the individual trajectories (e.g., by
#' pollutant concentrations) or create "layer control" menus to show/hide
#' different layers.
#'
#' @family interactive trajectory maps
#'
#' @param data *A data frame containing a HYSPLIT trajectory, perhaps accessed
#'   with [openair::importTraj()].*
#'
#'   **required**
#'
#'   A data frame containing HYSPLIT model outputs. If this data were not
#'   obtained using [openair::importTraj()].
#'
#' @param latitude,longitude *The decimal latitude/longitude.*
#'
#'  *default:* `"lat"` / `"lon"`
#'
#'   Column names representing the decimal latitude and longitude.
#'
#' @param colour *Column to be used for colouring each trajectory.*
#'
#'  *default:* `NULL`
#'
#'   This column may be numeric, character, factor or date(time). This will
#'   commonly be a pollutant concentration which has been joined (e.g., by
#'   [dplyr::left_join()]) to the trajectory data by "date".
#'
#' @param type *A method to condition the `data` for separate plotting.*
#'
#'  *default:* `NULL`
#'
#'   Used for splitting the trajectories into different groups which can be
#'   selected between using a "layer control" menu. Passed to
#'   [openair::cutData()].
#'
#' @param cols *Colours to use for plotting.*
#'
#'  *default:* `"default"`
#'
#'   The colours used for plotting, passed to [openair::openColours()].
#'
#' @param alpha *Transparency value for trajectories.*
#'
#'  *default:* `1`
#'
#'   A value between `0` (fully transparent) and `1` (fully opaque).
#'
#' @param npoints *Interval at which points are placed along the trajectory
#'   paths.*
#'
#'  *default:* `12`
#'
#'   A dot is placed every `npoints` along each full trajectory. For hourly back
#'   trajectories points are plotted every `npoints` hours. This helps to
#'   understand where the air masses were at particular times and get a feel for
#'   the speed of the air (points closer together correspond to slower moving
#'   air masses). Defaults to `12`.
#'
#' @param provider *The basemap to be used.*
#'
#'  *default:* `"OpenStreetMap"`
#'
#'   A single [leaflet::providers]. See
#'   <http://leaflet-extras.github.io/leaflet-providers/preview/> for a list of
#'   all base maps that can be used.
#'
#' @param legend.position *Position of the shared legend.*
#'
#'  *default:* `"topright"`
#'
#'   Where should the legend be placed? One of "topright", "topright",
#'   "bottomleft" or "bottomright". Passed to the `position` argument of
#'   [leaflet::addLegend()]. `NULL` defaults to "topright".
#'
#' @param legend.title *Title of the legend.*
#'
#'   *default:* `NULL`
#'
#'   By default, when `legend.title = NULL`, the function will attempt to
#'   provide a sensible legend title based on `colour`. `legend.title` allows
#'   users to overwrite this - for example, to include units or other contextual
#'   information. Users may wish to use HTML tags to format the title.
#'
#' @param legend.title.autotext *Automatically format the title of the legend?*
#'
#'   *default:* `TRUE`
#'
#'   When `legend.title.autotext = TRUE`, `legend.title` will be first run
#'   through [quickTextHTML()].
#'
#' @param control.collapsed *Show the layer control as a collapsed?*
#'
#'  *default:* `FALSE`
#'
#'   Should the "layer control" interface be collapsed? If `TRUE`, users will
#'   have to hover over an icon to view the options.
#'
#' @param control.position *Position of the layer control menu*
#'
#'  *default:* `"topright"`
#'
#'   Where should the "layer control" interface be placed? One of "topleft",
#'   "topright", "bottomleft" or "bottomright". Passed to the `position`
#'   argument of [leaflet::addLayersControl()].
#'
#' @param control Deprecated. Please use `type`.
#'
#' @inheritDotParams openair::cutData -x -type
#'
#' @returns A leaflet object.
#' @export
#'
#' @seealso [openair::trajPlot()]
#' @seealso [trajMapStatic()] for the static `ggplot2` equivalent of [trajMap()]
#'
#' @examples
#' \dontrun{
#' trajMap(traj_data, colour = "pm10")
#' }
#'
trajMap <-
  function(
    data,
    longitude = "lon",
    latitude = "lat",
    colour = NULL,
    type = NULL,
    cols = "default",
    alpha = 0.5,
    npoints = 12,
    provider = "OpenStreetMap",
    legend.position = "topright",
    legend.title = NULL,
    legend.title.autotext = TRUE,
    control.collapsed = FALSE,
    control.position = "topright",
    control = NULL,
    ...
  ) {
    # handle deprecated argument
    if (!is.null(control)) {
      lifecycle::deprecate_soft(
        when = "0.9.0",
        what = "trajMap(control)",
        with = "trajMap(type)"
      )
    }
    type <- type %||% control

    # make lat/lon easier to use
    names(data)[names(data) == longitude] <- "lon"
    names(data)[names(data) == latitude] <- "lat"

    # default colour is black
    fixedcol <- "black"

    # get factor version of date to reorder by "colour"
    data$datef <- factor(data$date)

    # if no "type", get a fake column
    type <- type %||% "default"
    data <- openair::cutData(x = data, type = type, ...)

    # initialise map
    map <- leaflet::leaflet() |>
      leaflet::addProviderTiles(provider = provider)

    # if "colour", create colour palette
    if (!is.null(colour)) {
      if (colour %in% names(data)) {
        data <- dplyr::arrange(data, .data$datef)

        if (
          inherits(data[[colour]], "factor") ||
            inherits(data[[colour]], "character")
        ) {
          pal <- leaflet::colorFactor(
            palette = openair::openColours(
              scheme = cols,
              n = length(unique(data[[colour]]))
            ),
            domain = data[[colour]]
          )
        } else if (inherits(data[[colour]], "POSIXct")) {
          pal <- leaflet::colorNumeric(
            palette = openair::openColours(scheme = cols),
            domain = as.numeric(data[[colour]], origin = "1964-10-22")
          )
        } else {
          pal <- leaflet::colorNumeric(
            palette = openair::openColours(scheme = cols),
            domain = data[[colour]]
          )
        }
      } else {
        fixedcol <- colour
      }
    }

    # make labels
    data <- dplyr::mutate(
      data,
      lab = stringr::str_glue(
        "<b>Arrival Date:</b> {date}<br>
                             <b>Trajectory Date:</b> {date2}<br>
                             <b>Lat:</b> {lat} | <b>Lon:</b> {lon}<br>
                             <b>Height:</b> {height} m | <b>Pressure:</b> {pressure} Pa"
      )
    )

    if (!is.null(colour)) {
      if (
        colour %in%
          names(data) &&
          !colour %in% c("date", "date2", "lat", "lon", "height", "pressure")
      ) {
        data$lab <- paste(
          data$lab,
          paste0("<b>", quickTextHTML(colour), ":</b> ", data[[colour]]),
          sep = "<br>"
        )
      }
    }

    # iterate over columns in "type" column
    for (j in seq_along(unique(data[[type]]))) {
      # get jth instance of "type"
      data2 <-
        dplyr::filter(data, .data[[type]] == unique(data[[type]])[[j]])

      # iterate over different arrival dates to plot separate trajectories
      for (i in seq_along(unique(data2$datef))) {
        # get line/points data
        ldata <-
          dplyr::filter(data2, .data$datef == unique(data2$datef)[[i]])
        pdata <-
          dplyr::filter(ldata, .data$hour.inc %% npoints == 0)

        lcolors <- fixedcol
        pcolors <- fixedcol
        # apply color pal if it exists
        if (!is.null(colour)) {
          if (colour %in% names(data)) {
            lcolors <- pal(ldata[[colour]])[1]
            pcolors <- pal(pdata[[colour]])
          }
        }

        # add points/lines to plot
        map <-
          leaflet::addPolylines(
            map = map,
            data = ldata,
            lng = ldata$lon,
            lat = ldata$lat,
            opacity = alpha,
            weight = 2,
            color = lcolors,
            group = as.character(unique(data[[type]])[[j]])
          ) |>
          leaflet::addCircleMarkers(
            data = pdata,
            radius = 3,
            stroke = FALSE,
            lng = pdata$lon,
            lat = pdata$lat,
            fillOpacity = alpha,
            color = pcolors,
            group = as.character(unique(data[[type]])[[j]]),
            popup = pdata$lab
          )
      }
    }

    # if "group" exists, add a legend
    if (!is.null(colour)) {
      legend.title <- legend.title %||% colour
      if (legend.title.autotext) {
        legend.title <- quickTextHTML(legend.title)
      }

      if (colour %in% names(data)) {
        if (inherits(data[[colour]], "POSIXct")) {
          map <-
            leaflet::addLegend(
              map,
              title = legend.title,
              position = check_legendposition(legend.position, FALSE),
              pal = pal,
              values = as.numeric(data[[colour]], origin = "1964-10-22"),
              labFormat = leaflet::labelFormat(
                transform = function(x) {
                  as.Date.POSIXct(x, origin = "1964-10-22")
                }
              )
            )
        } else {
          map <-
            leaflet::addLegend(
              map,
              title = legend.title,
              position = check_legendposition(legend.position, FALSE),
              pal = pal,
              values = data[[colour]]
            )
        }
      }
    }

    # if "control" exists, add the layer control menu
    if (type != "default") {
      map <-
        leaflet::addLayersControl(
          map,
          position = control.position,
          options = leaflet::layersControlOptions(
            collapsed = control.collapsed,
            autoZIndex = FALSE
          ),
          overlayGroups = as.character(unique(data[[type]]))
        )
    }

    map
  }
