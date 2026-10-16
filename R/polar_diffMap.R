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
    data = before,
    latitude = latitude,
    longitude = longitude
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  # auto limits
  if ("fixed" %in% limits) {
    cli::cli_abort(
      "{.code limits = 'fixed'} is currently not supported for {.fun diffMap}."
    )
  }
  theLimits <- resolve_scale(limits, "limits", free = NA, n = 2)

  # cut data
  before <- openair::cutData(x = before, type = type %||% "default", ...)
  after <- openair::cutData(x = after, type = type %||% "default", ...)

  # deal with popups - only `before` is used for popups/labels
  if (length(popup) > 1) {
    before <-
      quick_popup(
        data = before,
        popup = popup,
        latitude = latitude,
        longitude = longitude,
        control = type
      )
    popup <- "popup"
  }

  # prep data
  before <-
    prepMapData(
      data = before,
      pollutant = pollutant,
      control = type,
      "wd",
      x,
      latitude,
      longitude,
      popup,
      label
    )

  after <-
    prepMapData(
      data = after,
      pollutant = pollutant,
      control = type,
      "wd",
      x,
      latitude,
      longitude
    )

  # identify splitting column (defaulting to pollutant)
  if (length(pollutant) > 1) {
    split_col <- "pollutant_name"
  } else if (!is.null(type)) {
    before[type] <- as.factor(before[[type]])
    after[type] <- as.factor(after[[type]])
    split_col <- type
  } else {
    split_col <- "pollutant_name"
  }

  # arguments for function
  fun_args <- append(
    list(
      pollutant = "conc",
      x = x,
      limits = theLimits,
      cols = cols,
      theme = theme,
      key.position = key.position,
      plot = FALSE
    ),
    rlang::list2(...)
  )

  # define function
  fun <- function(before, after) {
    rlang::exec(
      openair::polarDiff,
      !!!append(
        list(before = before, after = after),
        fun_args
      )
    )
  }

  # plot and save static markers
  plots_df <-
    create_polar_markers(
      fun = fun,
      fun_args = fun_args,
      data = before,
      after = after,
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
      spec = if (!anyNA(theLimits)) legend_continuous(theLimits, cols),
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
