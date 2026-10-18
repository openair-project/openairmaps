#' Spatially interpolated dynamic and static maps
#'
#' @description `r lifecycle::badge("experimental")`
#'
#'   These functions create interpolated surfaces out of data at individual
#'   monitoring sites. This can be useful to 'fill in the gaps' to estimate
#'   pollution concentrations where no monitoring is occurring, or better
#'   identify geographical patterns in pollution data. [krigingMap()] creates a
#'   smooth spatially interpolated surface using either inverse distance
#'   weighting or point kriging. [voronoiMap()] creates a surface of 'closest
#'   observation' polygons. The kriging formula is currently always `pollutant ~
#'   1`; [krigingMap()] does not currently support more complex models.
#'
#'   When `type` is used, each `type` level is summarised and interpolated
#'   separately, but all levels share the same colour scale so that they can
#'   be compared.
#'
#' @inheritSection polarMap Customisation of static maps using ggplot2
#'
#' @inheritParams polarMap
#'
#' @param data *Input data table with pollutant and geo-spatial information.*
#'
#'   **required** | *scope:* dynamic & static
#'
#'   A data frame. The data frame must contain at least one numeric column to
#'   interpolate, plus a decimal latitude and longitude (or X/Y coordinate used
#'   in conjunction with `crs`).
#'
#' @param pollutant *Pollutant name.*
#'
#'   **required** | *scope:* dynamic & static
#'
#'   The column name of the pollutant to plot. Multiple `pollutants` are
#'   prohibited by this function.
#'
#' @param method *Spatial interpolation method.*
#'
#'  *default:* `"idw"` | *scope:* dynamic & static
#'
#'   The spatial interpolation method to use for [krigingMap()]. `"idw"` uses
#'   inverse distance weighting (IDW) which is simpler and faster. `"kriging"`
#'   uses full point kriging which is typically more accurate, but is also more
#'   complex and computationally intensive.
#'
#' @param labels,breaks *Discretise the map color scale.*
#'
#'  *default:* `NULL` | *scope:* dynamic & static
#'
#'   By default, a continuous colour scale is used. If `breaks` are provided,
#'   the colour scale will be discretised using [cut()]. `labels` can also be
#'   provided to customise how each factor level is labelled.
#'
#'   If the data extend beyond `breaks`, the outermost breaks are expanded to
#'   cover them so that no sites are left uncoloured. For example, `breaks =
#'   c(50, 100, 150)` would become `c(25, 100, 200)` for data ranging from 25
#'   to 200.
#'
#' @param statistic *Statistic for aggregating pollutant data.*
#'
#'   *default:* `"mean"` | *scope:* dynamic & static
#'
#'   Pollutant data will be aggregated by latitude & longitude; `statistic`
#'   controls how this is achieved. Possible statistics include:
#'
#'   - `"mean"`: the arithmetic mean (using [base::mean()])
#'   - `"median"`: the median (middle) value (using [stats::median()])
#'   - `"max"`: the maximum value (using [max()])
#'   - `"min"`: the maximum value (using [min()])
#'   - `"sd"`: the standard deviation (using [stats::sd()])
#'   - `"percentile"`: a percentile value, defined using the `percentile` argument (using [stats::quantile()])
#'
#'   To show this value in marker popups or labels, include `pollutant` in
#'   `popup` or `label` (e.g., `popup = c("site", "nox")`).
#'
#' @param percentile *The percentile when `statistic = "percentile"*
#'
#'  *default:* `95` | *scope:* dynamic & static
#'
#'   The percentile level used when `statistic = "percentile"`. The default is
#'   `95`, representing 95%. Should be between `0` and `100`.
#'
#' @param newdata *A spatial dataset of prediction locations.*
#'
#'  *default:* `NULL` | *scope:* dynamic & static
#'
#'   By default, a bounding box of all latitudes and longitudes are used for
#'   prediction, but this is often not useful or aesthetically pleasing.
#'   `newdata` should be a spatial data frame (constructed with
#'   [sf::st_as_sf()]). This may be a country or authority boundary relevant to
#'   the `data` input.
#'
#' @param limits *Specifier for the plot colour scale bounds.*
#'
#'   *default:* `NULL` | *scope:* dynamic & static
#'
#'   A numeric vector in the form `c(lower, upper)` used to define the colour
#'   scale. For example, `limits = c(0, 100)` would force the plot limits to
#'   span 0-100. If `NULL`, appropriate limits will be selected based on the
#'   range in `data[[pollutant]]`. Values outside of `limits` are given the
#'   colour of the nearest limit.
#'
#' @param popup *Content for marker popups on dynamic maps.*
#'
#'  *default:* `NULL` | *scope:* dynamic
#'
#'   Columns to be used as the HTML content for site marker popups on dynamic
#'   maps. Popups may be useful to show information about the individual sites
#'   (e.g., site names, codes, types, etc.). If a vector of column names are
#'   provided they are passed to [buildPopup()] using its default values.
#'
#'   The `pollutant` column shows the site `statistic` (i.e., what the markers
#'   are coloured by), labelled as such (e.g., "NO<sub>2</sub> (max)"). Any
#'   other numeric columns have many values at each site, so are averaged and
#'   labelled "(mean)". Names given to `popup` (e.g., `c("Site NOx" = "nox")`)
#'   are used instead of these labels.
#'
#' @param label *Content for marker hover-over on dynamic maps.*
#'
#'  *default:* `NULL` | *scope:* dynamic
#'
#'   Column to be used as the HTML content for hover-over labels. Labels are
#'   useful for the same reasons as popups, though are typically shorter. The
#'   `pollutant` column shows the site `statistic`, and other numeric columns
#'   are averaged at each site.
#'
#' @param alpha *Transparency value for interpolated surface.*
#'
#'  *default:* `0.8` | *scope:* dynamic & static
#'
#'   A value between 0 (fully transparent) and 1 (fully opaque).
#'
#' @param show.markers *Show original monitoring site markers?*
#'
#'  *default:* `TRUE` | *scope:* dynamic & static
#'
#'   When `TRUE`, the coordinates in the input `data` will be shown as coloured
#'   markers. Any `popup` or `label` is attached to these markers, so neither
#'   is shown when `show.markers = FALSE`.
#'
#' @param marker.border,voronoi.border *Border colour to use for markers and
#'   voronoi tiles.*
#'
#'   *default:* `"white"` | *scope:* dynamic & static
#'
#'   Any valid HTML colour (e.g., a hex code). Use `NA` for no border.
#'
#' @param legend *Draw a legend?*
#'
#'  *default:* `TRUE` | *scope:* dynamic & static
#'
#'   When `TRUE`, a legend will appear on the map identifying the colour scale.
#'
#' @param vgm *A variogram model*
#'
#'  *default:* `gstat::vgm(psill = 1, model = "Exp", range = 50, nugget = 1)` | *scope:* dynamic & static
#'
#'   The variogram model to use when `method = "kriging"`. Must be the output of
#'   [gstat::vgm()]. As the data are in latitude and longitude, `{gstat}`
#'   measures distances (e.g., the `range`) in kilometres.
#'
#' @param args.idw,args.variogram,args.fit.variogram,args.krige *Extra arguments
#'   to pass to spatial interpolation functions for [krigingMap()].*
#'
#'  *scope:* dynamic & static
#'
#'   Extra arguments passed to [gstat::idw()], [gstat::variogram()],
#'   [gstat::fit.variogram()], and [gstat::krige()]. [gstat::idw()] and
#'   [gstat::krige()] are silenced by default (`debug.level = 0`), but this can
#'   be overridden (e.g., `args.idw = list(debug.level = 1)`).
#'
#' @inheritDotParams openair::cutData -x -type
#'
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#'
#' @family spatial interpolation maps
#'
#' @rdname interpolate-map
#' @order 1
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
#' # get a UK shapefile
#' uk <- rnaturalearth::ne_countries(scale = 10, country = "united kingdom")
#'
#' # create spatially interpolated map
#' voronoiMap(
#'   daqi,
#'   pollutant = "poll_index",
#'   newdata = uk,
#'   statistic = "max",
#'   breaks = seq(0.5, 10.5, 1),
#'   labels = as.character(1:10),
#'   legend.title = "Max O3 DAQI",
#'   cols = "daqi"
#' )
#'
#' krigingMap(
#'   daqi,
#'   pollutant = "poll_index",
#'   newdata = uk,
#'   statistic = "max",
#'   legend.title = "Max O3 DAQI",
#'   cols = openair::openColours("daqi", n = 10),
#'   limits = c(1, 10)
#' )
#' }
#'
krigingMap <- function(
  data,
  pollutant = NULL,
  statistic = "mean",
  percentile = 95,
  newdata = NULL,
  method = c("idw", "kriging"),
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
  alpha = 0.8,
  show.markers = TRUE,
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
  vgm = gstat::vgm(psill = 1, model = "Exp", range = 50, nugget = 1),
  args.idw = list(debug.level = 0),
  args.variogram = list(),
  args.fit.variogram = list(),
  args.krige = list(debug.level = 0),
  ...
) {
  rlang::check_installed(c("terra", "stars", "gstat"))
  method <- rlang::arg_match(method)
  if (method == "kriging" && !inherits(vgm, "variogramModel")) {
    cli::cli_abort(
      "Please provide a {.fun gstat::vgm} output to {.arg vgm}. You have provided {.type {vgm}}."
    )
  }

  map <- interp_map_init(data, ...)

  # use the same grid for every `type` level
  stars_grid <- create_interp_grid(data_sf = map$data_sf, newdata = newdata)
  formula <- stats::as.formula(paste(pollutant, 1, sep = "~"))

  interpolate <- function(sites) {
    if (method == "idw") {
      interp <- rlang::exec(
        gstat::idw,
        !!!args.idw,
        formula = formula,
        locations = sites,
        newdata = stars_grid
      )
    } else {
      v <- rlang::exec(
        gstat::variogram,
        !!!args.variogram,
        object = formula,
        locations = sites
      )
      v.m <- rlang::exec(
        gstat::fit.variogram,
        !!!args.fit.variogram,
        object = v,
        model = vgm
      )
      interp <- rlang::exec(
        gstat::krige,
        !!!args.krige,
        formula = formula,
        locations = sites,
        newdata = stars_grid,
        model = v.m
      )
    }

    # keep only the predictions, named after the pollutant
    surface <- interp["var1.pred"]
    names(surface) <- pollutant
    surface
  }

  interp_map_draw(map, surface_fun = interpolate, show.markers = show.markers)
}

#' @param args.voronoi *Extra arguments to pass to spatial interpolation
#'   functions for [voronoiMap()].*
#'
#'  *scope:* dynamic & static
#'
#'   Extra arguments passed to [terra::voronoi()], with the exception of `x`
#'   which is dealt with by [voronoiMap()].
#'
#' @family spatial interpolation maps
#'
#' @rdname interpolate-map
#' @order 2
#' @export
voronoiMap <- function(
  data,
  pollutant = NULL,
  statistic = "mean",
  percentile = 95,
  newdata = NULL,
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
  alpha = 0.8,
  show.markers = TRUE,
  marker.border = "white",
  voronoi.border = "white",
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
  args.voronoi = list(),
  ...
) {
  rlang::check_installed(c("terra", "stars"))
  map <- interp_map_init(data, ...)

  # use the same boundary for every `type` level
  boundary <-
    create_interp_grid(data_sf = map$data_sf, newdata = newdata) |>
    sf::st_as_sf() |>
    dplyr::summarise()

  tessellate <- function(sites) {
    rlang::exec(terra::voronoi, !!!args.voronoi, x = terra::vect(sites)) |>
      sf::st_as_sf() |>
      # each tile has one value, so clipping it to the boundary doesn't change
      # it (this also avoids a warning from sf)
      sf::st_set_agr("constant") |>
      sf::st_intersection(boundary)
  }

  interp_map_draw(
    map,
    surface_fun = tessellate,
    show.markers = show.markers,
    voronoi.border = voronoi.border
  )
}
