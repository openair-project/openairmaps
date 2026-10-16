#' Percentile roses on dynamic and static maps
#'
#' The [percentileMap()] function creates a map using polar percentile roses as
#' markers. Any number of pollutants can be specified using the `pollutant`
#' argument, and multiple layers of markers can be created using `type`. By
#' default, these maps are dynamic and can be panned, zoomed, and otherwise
#' interacted with. Using the `static` argument allows for static images to be
#' produced instead.
#'
#' @inheritSection polarMap Parallel processing with mirai
#' @inheritSection polarMap Customisation of static maps using ggplot2
#' @family directional analysis maps
#'
#' @inheritParams polarMap
#' @param percentile *The percentile values for the colour scale bin.*
#'
#'  *default:* `c(25, 50, 75, 90, 95)` | *scope:* dynamic & static
#'
#'   The percentile value(s) to plot using [openair::percentileRose()]. Must be
#'   a vector of values between `0` and `100`. If `percentile = NA` then only a
#'   mean line will be shown.
#'
#' @param intervals *Specifier for the percentile rose radial axis intervals.*
#'
#'  *default:* `"fixed"` | *scope:* dynamic & static
#'
#'   One of:
#' - `"fixed"` (the default) which ensures all of the markers use the same radial axis scale.
#' - `"free"` which allows all of the markers to use different radial axis scales.
#' - A numeric vector defining a sequence of numbers to use as the intervals, e.g., `intervals = c(0, 10, 30, 50)`.
#'
#' @inheritDotParams openair::percentileRose
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#' @export
#'
#' @seealso [openair::percentileRose()]
#'
#' @examples
#' \dontrun{
#' percentileMap(polar_data,
#'   pollutant = "nox",
#'   provider = "CartoDB.Voyager"
#' )
#' }
percentileMap <- function(
  data,
  pollutant = NULL,
  percentile = c(25, 50, 75, 90, 95),
  intervals = "fixed",
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

  # auto limits
  intervals <- check_multipoll(intervals, pollutant)

  if ("fixed" %in% intervals) {
    if (is.null(pollutant)) {
      cli::cli_abort(
        c(
          "x" = "{.code pollutant} is missing with no default.",
          "i" = "Please provide a column of {.code data} which represents the pollutant(s) of interest."
        )
      )
    }

    data <-
      dplyr::mutate(data, latlng = paste(.data[[latitude]], .data[[longitude]]))

    fixed_type <- type
    if (is.null(type)) {
      fixed_type <- "default"
    }

    testplots <-
      openair::percentileRose(
        data,
        pollutant = pollutant,
        type = c("latlng", fixed_type),
        plot = FALSE,
        ...
      )$data

    theIntervals <- pretty(testplots[[pollutant]])
  } else if ("free" %in% intervals) {
    theIntervals <- NULL
  } else if (is.numeric(intervals)) {
    theIntervals <- intervals
  } else {
    cli::cli_abort(
      c(
        "!" = "Do not recognise {.field intervals} value of {.code {intervals}}",
        "i" = "{.field intervals} should be one of {.code 'fixed'}, {.code 'free'} or a numeric vector."
      )
    )
  }

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
      latitude,
      longitude,
      popup,
      label
    )

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
      percentile = percentile,
      plot = FALSE,
      cols = cols,
      theme = theme,
      key.position = key.position,
      intervals = theIntervals
    ),
    dots
  )

  # define function
  fun <- function(data) {
    rlang::exec(
      openair::percentileRose,
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
      # (percentile = NA only draws the mean, so there are no bands to show)
      spec = if (!anyNA(percentile)) {
        legend_discrete(labels = percentile_labels(percentile), cols = cols)
      },
      static = static,
      title = create_legend_title(
        static = static,
        legend.title.autotext = legend.title.autotext,
        legend.title = legend.title,
        str = "Percentile"
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

#' Labels for the bands drawn by openair::percentileRose()
#' @noRd
percentile_labels <- function(percentile) {
  percs <- sort(unique(c(0, percentile)))
  paste(utils::head(percs, -1), percs[-1], sep = " - ")
}
