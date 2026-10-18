# Polar map engine -------------------------------------------------------------
#
# The directional analysis maps (`polarMap()`, `annulusMap()`, etc.) all follow
# the same steps, which are implemented here in three stages:
#
# 1. `polar_map_init()` - check inputs and resolve shared settings.
# 2. `polar_map_prep()` - condition, tidy and split the data.
# 3. `polar_map_draw()` - draw the markers, the map, and the legend.
#
# Anything specific to one function (e.g., working out "fixed" scales) happens
# in that function between these stages.

#' Arguments shared by all polar `*Map()` functions
#'
#' `polar_map_init()` reads these from the calling function, so they don't
#' have to be passed through by hand. Every polar `*Map()` function must have
#' all of them as arguments - see `test-polar-engine.R`.
#' @noRd
polar_map_args <- c(
  "latitude",
  "longitude",
  "crs",
  "type",
  "popup",
  "label",
  "provider",
  "cols",
  "alpha",
  "theme",
  "key.position",
  "legend",
  "legend.position",
  "legend.title",
  "legend.title.autotext",
  "control.collapsed",
  "control.position",
  "control.autotext",
  "d.icon",
  "d.fig",
  "static",
  "static.nrow",
  "api_key",
  "progress",
  # removed, but kept so `polar_map_init()` can tell users to use `type`
  "control"
)

#' Start a polar map
#'
#' Collects the shared arguments (see `polar_map_args`) from the calling
#' function, checks them, and works out the latitude/longitude columns.
#' @param data The data, used to guess the latitude/longitude columns.
#' @param ... The `...` of the calling function.
#' @param env The calling function's environment.
#' @returns A list of settings, used by `polar_map_prep()` and
#'   `polar_map_draw()`.
#' @noRd
polar_map_init <- function(data, ..., env = rlang::caller_env()) {
  map <- rlang::env_get_list(env, polar_map_args)
  map$dots <- rlang::list2(...)

  # catch arguments replaced by `type` (`facet` would otherwise be silently
  # passed on via `...`)
  removed <- c(
    if (!is.null(map$control)) "control",
    intersect("facet", names(map$dots))
  )
  if (length(removed) > 0) {
    cli::cli_abort(
      c(
        "x" = "{.arg {removed}} {?has/have} been removed.",
        "i" = "Please use {.arg type} instead."
      ),
      call = env
    )
  }

  if (map$static) {
    check_installed_static()
  }

  # check basemap providers are valid
  map$provider <- check_providers(map$provider, map$static)
  map$legend.position <- check_legendposition(map$legend.position, map$static)

  # assume lat/lon
  latlon <- assume_latlon(
    data = data,
    latitude = map$latitude,
    longitude = map$longitude
  )
  map$latitude <- latlon$latitude
  map$longitude <- latlon$longitude

  map
}

#' Prepare data for a polar map
#'
#' Conditions the data by `type`, builds popups, selects/tidies the columns
#' needed for plotting, and works out which column splits the markers into
#' layers/panels (`split_col`).
#' @param vars Other columns needed by the openair function (e.g., `"wd"`).
#' @param after Optionally, a second data frame for two-table plots (i.e.,
#'   `diffMap()`). Popups/labels only come from `data`.
#' @param pairwise Is a pairwise statistic being used in `polarMap()`? If so,
#'   the pollutants aren't pivoted, so they make a single marker.
#' @returns `map`, with `data`, `after`, `split_col`, `pollutant` and `dropcol`
#'   added.
#' @noRd
polar_map_prep <- function(
  map,
  data,
  pollutant,
  vars,
  after = NULL,
  pairwise = FALSE
) {
  type <- map$type

  cut <- function(x) {
    rlang::exec(
      openair::cutData,
      x = x,
      type = type %||% "default",
      !!!map$dots
    )
  }

  # cut data
  data <- cut(data)

  # deal with popups & labels - numeric columns (e.g., pollutants, which are
  # reshaped by `prepMapData()`) have many values per marker, so any shown in a
  # popup/label are averaged at each marker
  is_numeric <- function(x) purrr::map_lgl(x, \(col) is.numeric(data[[col]]))

  if (length(map$popup) > 1 || any(is_numeric(map$popup))) {
    popup <- label_mean_popups(map$popup, data, map$latitude, map$longitude)
    data <-
      quick_popup(
        data = data,
        popup = popup,
        latitude = map$latitude,
        longitude = map$longitude,
        control = type
      )
    map$popup <- ".popup"
  }

  if (any(is_numeric(map$label))) {
    data <- dplyr::mutate(
      data,
      .label = signif(mean(.data[[map$label]], na.rm = TRUE), 3),
      .by = dplyr::all_of(c(map$latitude, map$longitude, type %||% "default"))
    )
    map$label <- ".label"
  }

  # prep data
  data <-
    prepMapData(
      data = data,
      pollutant = pollutant,
      control = type,
      vars,
      map$latitude,
      map$longitude,
      map$popup,
      map$label,
      .to_narrow = !pairwise,
      .pairwise = pairwise
    )

  if (!is.null(after)) {
    after <-
      prepMapData(
        data = cut(after),
        pollutant = pollutant,
        control = type,
        vars,
        map$latitude,
        map$longitude
      )
  }

  # identify splitting column (defaulting to pollutant)
  if (length(pollutant) > 1 && !pairwise) {
    split_col <- "pollutant_name"
  } else if (!is.null(type)) {
    data[type] <- as.factor(data[[type]])
    if (!is.null(after)) {
      after[type] <- as.factor(after[[type]])
    }
    split_col <- type
  } else {
    if (pairwise) {
      data$pollutant_name <- "DUMMY"
    }
    split_col <- "pollutant_name"
  }

  map$data <- data
  map$after <- after
  map$split_col <- split_col
  # pairwise statistics use two pollutants but only make one marker, so
  # shouldn't be faceted by pollutant
  map$pollutant <- if (pairwise) NULL else pollutant
  map$dropcol <- if (pairwise) pollutant else "conc"

  map
}

#' Complete the arguments for an openair function
#'
#' Adds the arguments shared by all polar `*Map()` functions (`plot`, `cols`,
#' etc.) and the user's `...` to those specific to one function.
#' @noRd
polar_fun_args <- function(map, fun_args) {
  dots <- map$dots
  dots$annotate <- dots$annotate %||% FALSE
  c(
    fun_args,
    list(
      plot = FALSE,
      cols = map$cols,
      theme = map$theme,
      key.position = map$key.position
    ),
    dots
  )
}

#' Draw a polar map
#'
#' Plots each marker with `fun`, places them on a dynamic or static map, and
#' adds a shared legend (if requested and possible).
#' @param fun The openair function (e.g., `openair::polarPlot`).
#' @param fun_args Arguments specific to `fun`, completed by
#'   `polar_fun_args()`.
#' @param legend_spec A function of the plotted markers which returns a legend
#'   specification for `add_polar_legend()` - e.g., using
#'   `legend_from_markers()`. `NULL` for no legend.
#' @param legend_str The default legend title.
#' @noRd
polar_map_draw <- function(
  map,
  fun,
  fun_args,
  legend_spec = NULL,
  legend_str = NULL
) {
  fun_args <- polar_fun_args(map, fun_args)

  # plot and save markers
  plots_df <-
    create_polar_markers(
      fun = fun,
      fun_args = fun_args,
      data = map$data,
      after = map$after,
      latitude = map$latitude,
      longitude = map$longitude,
      split_col = map$split_col,
      d.fig = map$d.fig,
      popup = map$popup,
      label = map$label,
      dropcol = map$dropcol,
      progress = map$progress
    )

  if (map$static) {
    # create static map - deals with basics & facets
    out <-
      create_static_map(
        plots_df = plots_df,
        latitude = map$latitude,
        longitude = map$longitude,
        split_col = map$split_col,
        pollutant = map$pollutant,
        facet = map$type,
        facet.nrow = map$static.nrow,
        api_key = map$api_key,
        d.icon = map$d.icon,
        crs = map$crs,
        provider = map$provider,
        alpha = map$alpha
      )
  } else {
    # create leaflet map
    out <-
      make_leaflet_map(
        plots_df,
        latitude = map$latitude,
        longitude = map$longitude,
        crs = map$crs,
        provider = map$provider,
        d.icon = map$d.icon,
        popup = map$popup,
        label = map$label,
        split_col = map$split_col,
        control.collapsed = map$control.collapsed,
        control.position = map$control.position,
        control.autotext = map$control.autotext,
        alpha = map$alpha
      )
  }

  # add shared legend
  if (map$legend && !is.null(legend_spec)) {
    out <- add_polar_legend(
      out,
      spec = legend_spec(plots_df),
      static = map$static,
      title = create_legend_title(
        static = map$static,
        legend.title.autotext = map$legend.title.autotext,
        legend.title = map$legend.title,
        str = paste(legend_str, collapse = if (map$static) ", " else ",<br>")
      ),
      position = map$legend.position,
      alpha = map$alpha,
      plots_df = plots_df,
      latitude = map$latitude,
      longitude = map$longitude,
      crs = map$crs
    )
  }

  out
}
