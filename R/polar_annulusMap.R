#' Polar annulus plots on dynamic and static maps
#'
#' The [annulusMap()] function creates a map using polar annulus plots as
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
#' @param period *Temporal period for radial axis.*
#'
#'   *default:* `"hour"` | *scope:* dynamic & static
#'
#'   Options are "hour" (the default, to plot diurnal variations), "season" to
#'   plot variation throughout the year, "weekday" to plot day of the week
#'   variation and "trend" to plot the trend by wind direction.
#' @inheritDotParams openair::polarAnnulus
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#' @export
#'
#' @seealso [openair::polarAnnulus()]
#'
#' @examples
#' \dontrun{
#' annulusMap(polar_data,
#'   pollutant = "nox",
#'   period = "hour",
#'   provider = "CartoDB.Voyager"
#' )
#' }
annulusMap <- function(
  data,
  pollutant = NULL,
  period = "hour",
  limits = "free",
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

  # auto limits
  limits <- check_multipoll(limits, pollutant)

  # `breaks` override `limits`
  if (!is.null(breaks)) {
    theLimits <- NA
  } else {
    theLimits <- resolve_scale(
      limits,
      "limits",
      fixed = range(
        fixed_scale_data(
          openair::polarAnnulus,
          data,
          pollutant = pollutant,
          latitude = map$latitude,
          longitude = map$longitude,
          type = map$type,
          period = period,
          ...
        )$pred,
        na.rm = TRUE
      ),
      n = 2
    )
  }

  map <- polar_map_prep(map, data, pollutant, c("wd", "date"))

  fun_args <- list(pollutant = "conc", period = period, limits = theLimits)

  # work out one set of breaks for all markers, so they share a legend
  if (!is.null(breaks)) {
    fun_args$breaks <- resolve_shared_breaks(
      fun = openair::polarAnnulus,
      fun_args = polar_fun_args(map, fun_args),
      data = map$data,
      breaks = breaks,
      values = \(x) x$pred,
      latitude = map$latitude,
      longitude = map$longitude,
      split_col = map$split_col
    )
  }

  polar_map_draw(
    map,
    fun = openair::polarAnnulus,
    fun_args = fun_args,
    legend_spec = \(plots_df) {
      legend_from_markers(
        plots_df,
        values = \(x) x$pred,
        limits = theLimits,
        cols = cols,
        trans = map$dots$trans %||% formals(openair::polarAnnulus)$trans
      )
    },
    legend_str = pollutant
  )
}
