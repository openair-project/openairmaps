#' Pollution roses on dynamic and static maps
#'
#' The [pollroseMap()] function creates a map using pollution roses as markers.
#' Any number of pollutants can be specified using the `pollutant` argument, and
#' multiple layers of markers can be created using `type`. By default, these
#' maps are dynamic and can be panned, zoomed, and otherwise interacted with.
#' Using the `static` argument allows for static images to be produced instead.
#'
#' @inheritSection polarMap Parallel processing with mirai
#' @inheritSection polarMap Customisation of static maps using ggplot2
#' @family directional analysis maps
#'
#' @inheritParams polarMap
#' @param statistic *The statistic to be applied to each data bin in the plot*
#'
#'  *default:* `"prop.mean"` | *scope:* dynamic & static
#'
#'   Options currently include `"prop.count"`, `"prop.mean"` and `"abs.count"`.
#'   `"prop.count"` sizes bins according to the proportion of the frequency of
#'   measurements.  Similarly, `"prop.mean"` sizes bins according to their
#'   relative contribution to the mean. `"abs.count"` provides the absolute
#'   count of measurements in each bin.
#'
#' @param breaks *Specifier for the number of breaks of the colour axis.*
#'
#'  *default:* `NULL` | *scope:* dynamic & static
#'
#'   Most commonly, the number of break points. If not specified, each marker
#'   will independently break its supplied data at approximately 6 sensible
#'   break points. When `breaks` are specified, all markers will use the same
#'   break points. Breaks can also be used to set specific break points. For
#'   example, the argument `breaks = c(0, 1, 10, 100)` breaks the data into
#'   segments <1, 1-10, 10-100, >100.
#'
#' @inheritDotParams openair::pollutionRose -breaks -mydata -pollutant -plot
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#' @export
#'
#' @seealso [openair::pollutionRose()]
#'
#' @examples
#' \dontrun{
#' pollroseMap(polar_data,
#'   pollutant = "nox",
#'   statistic = "prop.count",
#'   provider = "CartoDB.Voyager"
#' )
#' }
pollroseMap <- function(
  data,
  pollutant = NULL,
  statistic = "prop.count",
  breaks = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 1,
  theme = "default",
  key.position = "none",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  control.autotext = TRUE,
  d.icon = 200,
  d.fig = 3.5,
  static = FALSE,
  static.nrow = NULL,
  api_key = NULL,
  progress = TRUE,
  ...,
  control = NULL
) {
  if (static) {
    check_installed_static()
  }

  # check basemap providers are valid
  provider <- check_providers(provider, static)
  legend.position <- check_legendposition(legend.position, static)

  # check for old facet/control opts
  type <- type %||% check_facet_control(control = control, ...)

  # assume lat/lon
  latlon <- assume_latlon(
    data = data,
    latitude = latitude,
    longitude = longitude
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  # cut data
  data <- openair::cutData(x = data, type = type %||% "default", ...)

  # deal with popups
  if (length(popup) > 1) {
    data <-
      quick_popup(
        data = data,
        popup = popup,
        latitude = latitude,
        longitude = longitude,
        control = type
      )
    popup <- "popup"
  }

  # prep data
  data <-
    prepMapData(
      data = data,
      pollutant = pollutant,
      control = type,
      "wd",
      "ws",
      latitude,
      longitude,
      popup,
      label
    )

  # work out breaks
  # needs to happen before plotting to ensure same scales
  if (!is.null(breaks)) {
    theBreaks <-
      getBreaks(breaks = breaks, ws.int = NULL, vec = data$conc, polrose = TRUE)
  } else {
    theBreaks <- 6
  }

  # identify splitting column (defaulting to pollutant)
  if (length(pollutant) > 1) {
    split_col <- "pollutant_name"
  } else if (!is.null(type)) {
    data[type] <- as.factor(data[[type]])
    split_col <- type
  } else {
    split_col <- "pollutant_name"
  }

  # arguments for function
  dots <- rlang::list2(...)
  dots$annotate <- dots$annotate %||% FALSE
  fun_args <- append(
    list(
      pollutant = "conc",
      statistic = statistic,
      breaks = theBreaks,
      plot = FALSE,
      cols = cols,
      theme = theme,
      key.position = key.position
    ),
    dots
  )

  # define function
  fun <- function(data) {
    rlang::exec(
      openair::pollutionRose,
      !!!append(
        list(mydata = data),
        fun_args
      )
    )
  }

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
      progress = progress
    )

  if (static) {
    # create static map - deals with basics & facets
    map <-
      create_static_map(
        plots_df = plots_df,
        latitude = latitude,
        longitude = longitude,
        split_col = split_col,
        pollutant = pollutant,
        facet = type,
        facet.nrow = static.nrow,
        api_key = api_key,
        d.icon = d.icon,
        crs = crs,
        provider = provider,
        alpha = alpha
      )
  }

  if (!static) {
    # create leaflet map
    map <-
      make_leaflet_map(
        plots_df,
        latitude,
        longitude,
        crs,
        provider,
        d.icon,
        popup,
        label,
        split_col,
        control.collapsed,
        control.position,
        control.autotext,
        alpha
      )
  }

  # add shared legend
  if (legend) {
    map <- add_polar_legend(
      map,
      spec = legend_from_markers(
        plots_df,
        values = rose_intervals,
        cols = cols
      ),
      static = static,
      title = create_legend_title(
        static = static,
        legend.title.autotext = legend.title.autotext,
        legend.title = legend.title,
        str = paste(pollutant, collapse = if (static) ", " else ",<br>")
      ),
      position = legend.position,
      alpha = alpha,
      plots_df = plots_df,
      latitude = latitude,
      longitude = longitude
    )
  }

  # return map
  return(map)
}
