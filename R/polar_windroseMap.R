#' Wind roses on dynamic and static maps
#'
#' The [windroseMap()] function creates a map using wind roses as markers.
#' Multiple layers of markers can be created using the `type` argument. By
#' default, these maps are dynamic and can be panned, zoomed, and otherwise
#' interacted with. Using the `static` argument allows for static images to be
#' produced instead.
#'
#' @inheritSection polarMap Parallel processing with mirai
#' @inheritSection polarMap Customisation of static maps using ggplot2
#' @family directional analysis maps
#'
#' @inheritParams polarMap
#' @param data *Input data table with wind and geo-spatial information.*
#'
#'   **required** | *scope:* dynamic & static
#'
#'   A data frame. The data frame must contain the data to plot the directional
#'   analysis marker, which includes wind speed (`ws`) and wind direction
#'   (`wd`). In addition, `data` must include a decimal latitude and longitude
#'   (or X/Y coordinate used in conjunction with `crs`).
#'
#' @param ws.int *The wind speed interval of the colour axis.*
#'
#'  *default:* `2` | *scope:* dynamic & static
#'
#'   The wind speed interval. Default is 2 m/s but for low met masts with low
#'   mean wind speeds a value of 1 or 0.5 m/s may be better.
#'
#' @param breaks *Specifier for the number of breaks of the colour axis.*
#'
#'  *default:* `4` | *scope:* dynamic & static
#'
#'   Most commonly, the number of break points for wind speed in
#'   [openair::windRose()]. For the `ws.int` default of `2`, the default
#'   `breaks`, `4`, generates the break points 2, 4, 6, and 8. Breaks can also
#'   be used to set specific break points. For example, the argument `breaks =
#'   c(0, 1, 10, 100)`` breaks the data into segments <1, 1-10, 10-100, >100.
#'
#' @inheritDotParams openair::windRose
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#'
#' @export
#'
#' @seealso [openair::windRose()]
#'
#' @examples
#' \dontrun{
#' windroseMap(polar_data,
#'   provider = "CartoDB.Voyager"
#' )
#' }
windroseMap <- function(
  data,
  ws.int = 2,
  breaks = 4,
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

  # need to put ws in a separate column to work with the rest of openairmaps
  # utilities...
  data$ws_dup <- data$ws
  map <- polar_map_prep(map, data, "ws_dup", c("ws", "wd"))

  # work out breaks - needs to happen before plotting to ensure same scales
  breaks <- getBreaks(breaks, ws.int, map$data$conc, polrose = FALSE)

  polar_map_draw(
    map,
    fun = openair::windRose,
    fun_args = list(ws.int = ws.int, breaks = breaks),
    legend_spec = \(plots_df) {
      legend_from_markers(plots_df, values = rose_intervals, cols = cols)
    },
    legend_str = "Wind Speed"
  )
}
