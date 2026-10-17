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
#' @param provider *The basemap(s) to be used.*
#'
#'  *default:* `"OpenStreetMap"`
#'
#'   Any number of [leaflet::providers]. See
#'   <http://leaflet-extras.github.io/leaflet-providers/preview/> for a list of
#'   all base maps that can be used. If multiple base maps are provided, they
#'   can be toggled between using a "layer control" interface. By default, the
#'   interface will use the provider names as labels, but users can define their
#'   own using a named vector (e.g., `c("Default" = "OpenStreetMap", "Satellite"
#'   = "Esri.WorldImagery")`)
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
#' @inheritDotParams openair::cutData -x -type
#'
#' @returns A leaflet object.
#' @export
#'
#' @seealso [openair::trajPlot()]
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
    ...
  ) {
    # make lat/lon easier to use
    names(data)[names(data) == longitude] <- "lon"
    names(data)[names(data) == latitude] <- "lat"

    # identify individual trajectories
    data$trajid <- traj_id(data)

    # if no "type", get a fake column
    type <- type %||% "default"
    data <- openair::cutData(x = data, type = type, ...)

    # check basemap providers are valid
    provider <- check_providers(provider, static = FALSE)

    # initialise map
    map <- leaflet::leaflet() |>
      add_basemaps(provider)

    # "colour" is either a column to colour by, or a single colour (by
    # default, black)
    colour_col <- !is.null(colour) && colour %in% names(data)
    fixedcol <- if (!is.null(colour) && !colour_col) colour else "black"

    # if colouring by a column, create colour palette
    if (colour_col) {
      data <- dplyr::arrange(data, .data$date)

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
    }

    # make labels
    # (add the "colour" column too, unless it's already in the label)
    extra <- NULL
    if (
      colour_col &&
        !colour %in% c("date", "date2", "lat", "lon", "height", "pressure")
    ) {
      extra <- colour
    }
    data <- build_traj_labels(data, extra = extra)

    # iterate over columns in "type" column
    for (j in seq_along(unique(data[[type]]))) {
      # get jth instance of "type"
      data2 <-
        dplyr::filter(data, .data[[type]] == unique(data[[type]])[[j]])

      # iterate over individual trajectories (i.e., each arrival date and
      # receptor) to plot them separately
      for (i in seq_along(unique(data2$trajid))) {
        # get line data (addTrajPaths() does its own npoints-based filtering
        # for the points)
        ldata <-
          dplyr::filter(data2, .data$trajid == unique(data2$trajid)[[i]])

        lcolors <- fixedcol
        pcolors <- fixedcol
        # apply color pal if it exists
        if (colour_col) {
          lcolors <- pal(ldata[[colour]])[1]
          pcolors <- pal(ldata[[colour]])
        }

        # add line + points to plot
        map <-
          addTrajPaths(
            map,
            data = ldata,
            npoints = npoints,
            group = as.character(unique(data[[type]])[[j]]),
            color = lcolors,
            markerColor = pcolors,
            opacity = alpha,
            fillOpacity = alpha
          )
      }
    }

    # if colouring by a column, add a legend
    if (colour_col) {
      legend.title <- create_legend_title(
        static = FALSE,
        legend.title.autotext = legend.title.autotext,
        legend.title = legend.title,
        str = colour
      )

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

    # add the layer control menu - "type" levels can be toggled on and off
    map <- add_layer_control(
      map,
      provider = provider,
      groups = if (type != "default") unique(data[[type]]),
      groups_as = "overlay",
      position = control.position,
      collapsed = control.collapsed
    )

    map
  }
