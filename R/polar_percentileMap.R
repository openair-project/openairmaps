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
#'   provider = "Esri.WorldGrayCanvas"
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
  map <- polar_map_init(data, ...)

  # auto limits
  # ("fixed" is the default, so only warn if it was asked for)
  intervals <- check_multipoll(
    intervals,
    pollutant,
    arg = "intervals",
    warn = !missing(intervals)
  )

  theIntervals <- resolve_scale(
    intervals,
    "intervals",
    fixed = pretty(
      fixed_scale_data(
        openair::percentileRose,
        data,
        pollutant = pollutant,
        latitude = map$latitude,
        longitude = map$longitude,
        type = map$type,
        percentile = percentile,
        ...
      )[[pollutant]]
    )
  )

  map <- polar_map_prep(map, data, pollutant, "wd")

  polar_map_draw(
    map,
    fun = openair::percentileRose,
    fun_args = list(
      pollutant = "conc",
      percentile = percentile,
      intervals = theIntervals
    ),
    # (percentile = NA only draws the mean, so there are no bands to show)
    legend_spec = if (!anyNA(percentile)) {
      \(plots_df) {
        legend_discrete(labels = percentile_labels(percentile), cols = cols)
      }
    },
    legend_str = "Percentile"
  )
}

#' Labels for the bands drawn by openair::percentileRose()
#' @noRd
percentile_labels <- function(percentile) {
  percs <- sort(unique(c(0, percentile)))
  paste(utils::head(percs, -1), percs[-1], sep = " - ")
}
