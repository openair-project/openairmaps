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
#'  *default:* `NULL`
#'
#'   Column names representing the decimal latitude and longitude. If not
#'   provided, will be automatically inferred from data by looking for a column
#'   named "lat"/"latitude" or "lon"/"lng"/"long"/"longitude"
#'   (case-insensitively), such as the "lat" and "lon" columns returned by
#'   [openair::importTraj()].
#'
#' @param colour *Column to be used for colouring each trajectory.*
#'
#'  *default:* `NULL`
#'
#'   This column may be numeric, character, factor or date(time). This will
#'   commonly be a pollutant concentration which has been joined (e.g., by
#'   [dplyr::left_join()]) to the trajectory data by "date". Alternatively, a
#'   single colour (e.g., `"red"` or `"#FF0000"`) used for every trajectory. If
#'   `NULL`, trajectories are drawn in black.
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
#'  *default:* `"turbo"`
#'
#'   The colours used for plotting, passed to [openair::openColours()].
#'
#' @param alpha *Transparency value for trajectories.*
#'
#'  *default:* `0.5`
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
#'   Where should the legend be placed? One of "topright", "topleft",
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
    latitude = NULL,
    longitude = NULL,
    colour = NULL,
    type = NULL,
    cols = "turbo",
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
    latlon <- assume_latlon(data, latitude = latitude, longitude = longitude)
    names(data)[names(data) == latlon$longitude] <- "lon"
    names(data)[names(data) == latlon$latitude] <- "lat"

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
    if (!is.null(colour) && !colour_col && !is_colour(colour)) {
      cli::cli_abort(
        c(
          "x" = "{.arg colour} must be a column of {.arg data} or a single colour.",
          "i" = "{.val {colour}} is neither."
        )
      )
    }
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
    type_levels <- level_order(data[[type]])
    for (j in seq_along(type_levels)) {
      # get jth instance of "type"
      data2 <- dplyr::filter(data, .data[[type]] == type_levels[[j]])

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
            group = as.character(type_levels[[j]]),
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
            opacity = alpha,
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
            opacity = alpha,
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
      groups = if (type != "default") type_levels,
      groups_as = "overlay",
      position = control.position,
      collapsed = control.collapsed
    )

    map
  }
