#' Spatially interpolated dynamic and static maps
#'
#' [idwMap()] is the simplest function
#'
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
#' @param method *Spatial interpolate method.*
#'
#'  *default:* `"idw"` | *scope:* dynamic & static
#'
#'  The spatial interpolation method to use.
#'
#' @param statistic *Statistic for aggregating pollutant data.*
#'
#'   *default:* `"mean"` | *scope:* dynamic & static
#'
#'   Pollutant data will be aggregated by latitude & longitude; `statistic`
#'   controls how this is achieved. Possible statistics include:
#'
#'   - `"mean"`: the arithmetic mean (using [mean()])
#'   - `"median"`: the median (middle) value (using [stats::median()])
#'   - `"max"`: the maximum value (using [max()])
#'   - `"min"`: the maximum value (using [min()])
#'
#'   If `data` only has one value per latitude & longitude coordinate,
#'   `statistic` will do nothing.
#'
#' @param newdata
#'
#' @param limits *Specifier for the plot colour scale bounds.*
#'
#'   *default:* `NULL` | *scope:* dynamic & static
#'
#'   A numeric vector in the form `c(lower, upper)` used to define the colour
#'   scale. For example, `limits = c(0, 100)` would force the plot limits to
#'   span 0-100. If `NULL`, appropriate limits will be selected based on the
#'   range in `data[[pollutant]]`.
#'
#' @param type *A method to condition the `data` for separate plotting.*
#'
#'  *default:* `NULL` | *scope:* dynamic & static
#'
#'   Used for splitting the input data into different groups, passed to the
#'   `type` argument of [openair::cutData()]. When `type` is specified:
#'
#'   - *Dynamic*: The different data splits can be toggled between using a "layer control" menu.
#'
#'   - *Static:*: The data splits will each appear in a different panel.
#'
#' @param alpha *Transparency value for interpolated surface.*
#'
#'  *default:* `1` | *scope:* dynamic & static
#'
#'   A value between 0 (fully transparent) and 1 (fully opaque).
#'
#' @param show_markers *Show original monitoring site markers?*
#'
#'  *default:* `TRUE` | *scope:* dynamic & static
#'
#'   When `TRUE`, the coordinates in the input `data` will be shown as coloured
#'   markers.
#'
#' @param legend *Draw a legend?*
#'
#'  *default:* `TRUE` | *scope:* dynamic & static
#'
#'   When `TRUE`, a legend will appear on the map identifying the colour scale.
#'
#' @inheritDotParams gstat::idw -formula -locations -newdata
#'
#' @returns Either:
#'
#'  - *Dynamic:* A leaflet object
#'  - *Static:* A `ggplot2` object using [ggplot2::coord_sf()] coordinates with a `ggspatial` basemap
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # an artificial example
#' idwMap(polar_data, "no2")
#' }
krigeMap <- function(
  data,
  pollutant = NULL,
  statistic = "mean",
  method = c("idw", "voronoi", "kriging"),
  newdata = NULL,
  limits = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 0.8,
  show_markers = TRUE,
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  control.autotext = TRUE,
  static = FALSE,
  static.nrow = NULL,
  ...
) {
  latlon <- assume_latlon(
    data,
    latitude = latitude,
    longitude = longitude,
    quiet = FALSE
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  fun <- switch(
    statistic,
    "mean" = \(x) mean(x, na.rm = TRUE),
    "median" = \(x) stats::median(x, na.rm = TRUE),
    "max" = \(x) ifelse(all(is.na(x)), NA, max(x, na.rm = TRUE)),
    "min" = \(x) ifelse(all(is.na(x)), NA, min(x, na.rm = TRUE))
  )

  data_sf <-
    data |>
    dplyr::summarise(
      {{ pollutant }} := fun(.data[[pollutant]]),
      .by = dplyr::all_of(c(latitude, longitude))
    ) |>
    sf::st_as_sf(
      coords = c(longitude, latitude),
      crs = crs
    ) |>
    sf::st_transform(crs = 4326) |>
    tidyr::drop_na(dplyr::all_of(pollutant)) |>
    dplyr::filter(!is.infinite(.data[[pollutant]]))

  if (is.null(newdata)) {
    stars_grid <-
      sf::st_bbox(data_sf) |>
      stars::st_as_stars(crs = 4326)
  } else {
    stars_grid <-
      sf::st_bbox(newdata) |>
      stars::st_as_stars(crs = 4326) |>
      sf::st_crop(newdata)
  }

  browser()

  interp <- terra::voronoi(terra::vect(data_sf))

  interp <- gstat::idw(
    as.formula(paste(pollutant, 1, sep = "~")),
    data_sf,
    stars_grid,
    ...
  )

  vals <- limits %||%
    pretty(c(0, data_sf[[pollutant]], as.vector(interp$var1.pred)))

  if (!static) {
    pal <-
      leaflet::colorNumeric(
        palette = openair::openColours(cols),
        domain = vals,
        na.color = NA
      )

    map <-
      leaflet::leaflet() |>
      leaflet::addProviderTiles(provider = provider) |>
      leaflet::addRasterImage(
        x = terra::rast(interp)[[1]],
        opacity = alpha,
        colors = pal
      )

    if (show_markers) {
      map <-
        leaflet::addCircleMarkers(
          map = map,
          data = data_sf,
          fillColor = pal(data_sf[[pollutant]]),
          opacity = 1,
          fillOpacity = 1,
          weight = 2,
          color = "white",
          radius = 4
        )
    }

    if (legend) {
      map <-
        leaflet::addLegend(
          map = map,
          pal = pal,
          values = vals,
          title = ifelse(
            legend.title.autotext,
            quickTextHTML(legend.title %||% pollutant),
            legend.title %||% pollutant
          ),
          position = legend.position
        )
    }
  }

  if (static) {
    map <- ggplot2::ggplot() +
      ggspatial::annotation_map_tile(zoomin = 0, cachedir = tempdir()) +
      stars::geom_stars(data = interp, alpha = alpha)

    if (show_markers) {
      map <- map +
        ggplot2::geom_sf(
          data = data_sf,
          ggplot2::aes(fill = .data[[pollutant]]),
          shape = 21,
          color = "white"
        )
    }

    map <- map +
      ggplot2::coord_sf(crs = 4326L) +
      ggplot2::scale_fill_gradientn(
        limits = range(vals),
        colors = openair::openColours(cols),
        na.value = NA
      ) +
      theme_static() +
      ggplot2::labs(
        x = NULL,
        y = NULL,
        fill = openair::quickText(
          legend.title %||% pollutant,
          auto.text = legend.title.autotext
        )
      )
  }

  return(map)
}
