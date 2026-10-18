#' Polar frequency plots on dynamic and static maps
#'
#' The [freqMap()] function creates a map using polar frequency plots as
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
#' @param statistic *The statistic that should be applied to each wind
#'  speed/direction bin.*
#'
#'  *default:* `"mean"` | *scope:* dynamic & static
#'
#'  Can be "frequency", "mean", "median", "max" (maximum), "stdev" (standard
#'  deviation) or "weighted.mean". The option "frequency" is the simplest and
#'  plots the frequency of wind speed/direction in different bins. The scale
#'  therefore shows the counts in each bin. The option "mean" (the default) will
#'  plot the mean concentration of a pollutant (see next point) in wind
#'  speed/direction bins, and so on.  Finally, "weighted.mean" will plot the
#'  concentration of a pollutant weighted by wind speed/direction. Each segment
#'  therefore provides the percentage overall contribution to the total
#'  concentration. Note that for options other than "frequency", it is necessary
#'  to also provide the name of a pollutant. See function [openair::cutData()]
#'  for further details.
#'
#' @param breaks *Specifier for the breaks of the plot colour scale.*
#'
#'   *default:* `"free"` | *scope:* dynamic & static
#'
#'   One of:
#' - `"fixed"` which ensures all of the markers use the same colour scale.
#' - `"free"` (the default) which allows all of the markers to use different
#'   colour scales.
#' - A numeric vector defining a sequence of numbers to use as the breaks. The
#'   sequence could represent one with equal spacing, e.g., `breaks = seq(0,
#'   100, 10)` - a scale from 0-10 in intervals of 10, or a more flexible
#'   sequence, e.g., `breaks = c(0, 1, 5, 7, 10)`, which may be useful for some
#'   situations.
#' @inheritDotParams openair::polarFreq
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#' @export
#'
#' @seealso [openair::polarFreq()]
#'
#' @examples
#' \dontrun{
#' freqMap(polar_data,
#'   pollutant = "nox",
#'   statistic = "mean",
#'   provider = "Esri.WorldGrayCanvas"
#' )
#' }
freqMap <- function(
  data,
  pollutant = NULL,
  statistic = "mean",
  breaks = "free",
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
  map <- polar_map_init(data, ...)

  # allow no pollutant when statistic = "frequency"
  if (statistic == "frequency") {
    data$dummy <- seq_len(nrow(data))
    lab <- "Frequency"
    pollutant <- "dummy"
  } else {
    lab <- pollutant
  }

  # auto limits
  breaks <- check_multipoll(breaks, pollutant, arg = "breaks")

  # breaks are always calculated on untransformed weights, so override any
  # `trans` given in `...`
  fixed_args <- map$dots
  fixed_args$trans <- FALSE

  theBreaks <- resolve_scale(
    breaks,
    "breaks",
    fixed = pretty(
      rlang::exec(
        fixed_scale_data,
        openair::polarFreq,
        data,
        pollutant = pollutant,
        latitude = map$latitude,
        longitude = map$longitude,
        type = map$type,
        statistic = statistic,
        !!!fixed_args
      )$weights,
      n = 10
    )
  )

  map <- polar_map_prep(map, data, pollutant, c("wd", "ws"))

  polar_map_draw(
    map,
    fun = openair::polarFreq,
    fun_args = list(
      pollutant = "conc",
      breaks = theBreaks,
      statistic = statistic
    ),
    legend_spec = \(plots_df) {
      legend_from_markers(
        plots_df,
        values = \(x) x$weights,
        limits = map$dots$limits,
        cols = cols,
        trans = map$dots$trans %||% formals(openair::polarFreq)$trans
      )
    },
    legend_str = lab
  )
}
