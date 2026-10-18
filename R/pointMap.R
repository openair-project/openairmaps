#' Site average concentrations on dynamic and static maps
#'
#' [pointMap()] summarises pollutant data at each monitoring site (e.g., taking
#' the mean concentration) and shows the result as coloured circles on a map.
#' It is the simplest way to compare concentrations across a network of sites.
#' Unlike [krigingMap()] and [voronoiMap()], no attempt is made to estimate
#' concentrations away from the sites themselves. By default, these maps are
#' dynamic and can be panned, zoomed, and otherwise interacted with. Using the
#' `static` argument allows for static images to be produced instead.
#'
#' When `type` is used, the data are summarised separately for each `type`
#' level, but all levels share the same colour scale so that they can be
#' compared.
#'
#' @inheritSection polarMap Customisation of static maps using ggplot2
#'
#' @inheritParams krigingMap
#'
#' @param alpha *Transparency value for the site markers.*
#'
#'  *default:* `1` | *scope:* dynamic & static
#'
#'   A value between 0 (fully transparent) and 1 (fully opaque).
#'
#' @param marker.border *Border colour to use for the site markers.*
#'
#'   *default:* `"white"` | *scope:* dynamic & static
#'
#'   Any valid HTML colour (e.g., a hex code). Use `NA` for no border.
#'
#' @inheritDotParams openair::cutData -x -type
#'
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#'
#' @seealso [krigingMap()] and [voronoiMap()] to spatially interpolate between
#'   the sites.
#' @export
#'
#' @examples
#' \dontrun{
#' # import ozone DAQI
#' daqi <-
#'   openair::importUKAQ(
#'     pollutant = "o3",
#'     year = 2020,
#'     source = "aurn",
#'     data_type = "daqi",
#'     meta = TRUE
#'   )
#'
#' # maximum DAQI at each site
#' pointMap(
#'   daqi,
#'   pollutant = "poll_index",
#'   statistic = "max",
#'   breaks = seq(0.5, 10.5, 1),
#'   labels = as.character(1:10),
#'   legend.title = "Max O3 DAQI",
#'   cols = "daqi"
#' )
#' }
pointMap <- function(
  data,
  pollutant = NULL,
  statistic = "mean",
  percentile = 95,
  breaks = NULL,
  labels = NULL,
  limits = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 1,
  marker.border = "white",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  control.autotext = TRUE,
  static = FALSE,
  static.nrow = NULL,
  api_key = NULL,
  ...
) {
  map <- interp_map_init(data, ...)
  interp_map_draw(map)
}
