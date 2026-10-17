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
  map <- polar_map_init(data, ...)
  map <- polar_map_prep(map, data, pollutant, vars = c("wd", "ws"))

  # work out breaks - needs to happen before plotting to ensure same scales
  if (!is.null(breaks)) {
    breaks <- getBreaks(breaks, NULL, map$data$conc, polrose = TRUE)
  }

  polar_map_draw(
    map,
    fun = openair::pollutionRose,
    fun_args = list(
      pollutant = "conc",
      statistic = statistic,
      breaks = breaks %||% 6
    ),
    legend_spec = \(plots_df) {
      legend_from_markers(plots_df, values = rose_intervals, cols = cols)
    },
    legend_str = pollutant
  )
}
