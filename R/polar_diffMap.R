#' Bivariate polar 'difference' plots on dynamic and static maps
#'
#' The [diffMap()] function creates a map using bivariate polar plots as
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
#' @inheritParams openair::polarDiff
#' @inheritParams polarMap
#'
#' @param limits *Limits for the plot colour scale.*
#'
#'  *default:* `"free"` | *scope:* dynamic & static
#'
#'   One of:
#'  - `"free"` (the default) which allows all of the markers to use different
#'   colour scales.
#'  - A numeric vector in the form `c(lower, upper)` used to define the colour
#'   scale. For example, `limits = c(-10, 10)` would force the plot limits to
#'   span -10 to 10. It is recommended to use a symmetrical limit scale (along
#'   with a "diverging" colour palette) for effective visualisation.
#'
#'   Note that the `"fixed"` option is not supported in [diffMap()].
#'
#' @param cols *Colours to use for plotting.*
#'
#'  *default:* `rev(openair::openColours("RdBu", 10))` | *scope:* dynamic & static
#'
#'   The colours used for plotting, passed to [openair::openColours()].  It is
#'   recommended to use a "diverging" colour palette (along with a symmetrical
#'   `limit` scale) for effective visualisation.
#'
#' @inheritDotParams openair::polarPlot
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#' @export
#'
#' @seealso [openair::polarDiff()]
#'
#' @examples
#' \dontrun{
#' # NB: "after" is some dummy data to demonstrate functionality
#' diffMap(
#'   before = polar_data,
#'   after = dplyr::mutate(polar_data, nox = jitter(nox, factor = 5)),
#'   pollutant = "nox"
#' )
#' }
diffMap <- function(
  before,
  after,
  pollutant = NULL,
  x = "ws",
  limits = "free",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = rev(openair::openColours("RdBu", 10)),
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
  map <- polar_map_init(before, ...)

  # auto limits
  if ("fixed" %in% limits) {
    cli::cli_abort(
      "{.code limits = 'fixed'} is currently not supported for {.fun diffMap}."
    )
  }
  theLimits <- resolve_scale(limits, "limits", free = NA, n = 2)

  # only `before` is used for popups/labels
  map <- polar_map_prep(map, before, pollutant, c("wd", x), after = after)

  polar_map_draw(
    map,
    fun = openair::polarDiff,
    fun_args = list(pollutant = "conc", x = x, limits = theLimits),
    legend_spec = \(plots_df) {
      if (!anyNA(theLimits)) legend_continuous(theLimits, cols)
    },
    legend_str = pollutant
  )
}
