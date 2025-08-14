#' Spatially interpolated dynamic and static maps
#'
#' These functions create interpolated surfaces out of data at individual
#' monitoring sites. This can be useful to 'fill in the gaps' to estimate
#' pollution concentrations where no monitoring is occurring, or better identify
#' geographical patterns in pollution data. [krigingMap()] creates a smooth
#' spatially interpolated surface using either inverse distance weighting or
#' point kriging. [voronoiMap()] creates a surface of 'closest observation'
#' polygons. The kriging formula is currently always `pollutant ~ 1`;
#' [krigingMap()] does not currently support more complex models.
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
#'   - `"sd"`: the standard deviation (using [stats::sd()])
#'   - `"percentile"`: a percentile value, defined using the `percentile` argument (using [stats::quantile()])
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
#'   range in `data[[pollutant]]`.
#'
#' @param alpha *Transparency value for interpolated surface.*
#'
#'  *default:* `1` | *scope:* dynamic & static
#'
#'   A value between 0 (fully transparent) and 1 (fully opaque).
#'
#' @param show.markers *Show original monitoring site markers?*
#'
#'  *default:* `TRUE` | *scope:* dynamic & static
#'
#'   When `TRUE`, the coordinates in the input `data` will be shown as coloured
#'   markers.
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
#'  *default:* `gstat::vgm(psill = 1, model = "Exp", range = 50000, nugget = 1)` | *scope:* dynamic & static
#'
#'   The variogram model to use when `method = "kriging"`. Must be the output of
#'   [gstat::vgm()].
#'
#' @param args.idw,args.variogram,args.fit.variogram,args.krige *Extra arguments
#'   to pass to spatial interpolation functions for [krigingMap()].*
#'
#'  *scope:* dynamic & static
#'
#'   Extra arguments passed to [gstat::idw()], [gstat::vgm()],
#'   [gstat::fit.variogram()], and [gstat::krige()].
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
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 0.8,
  show.markers = TRUE,
  marker.border = "white",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  static = FALSE,
  vgm = gstat::vgm(psill = 1, model = "Exp", range = 50000, nugget = 1),
  args.idw = list(),
  args.variogram = list(),
  args.fit.variogram = list(),
  args.krige = list()
) {
  rlang::check_installed(c("terra", "stars", "gstat"))
  method <- rlang::arg_match(method)

  latlon <- assume_latlon(
    data,
    latitude = latitude,
    longitude = longitude,
    quiet = FALSE
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  data_sf <- prepare_sf_data(
    data = data,
    statistic = statistic,
    percentile = percentile,
    pollutant = pollutant,
    latitude = latitude,
    longitude = longitude,
    crs = crs
  )

  stars_grid <- create_interp_grid(data_sf = data_sf, newdata = newdata)

  if (method == "idw") {
    args.idw <- append(
      args.idw,
      list(
        formula = stats::as.formula(paste(pollutant, 1, sep = "~")),
        locations = data_sf,
        newdata = stars_grid
      )
    )
    interp <- rlang::exec(gstat::idw, !!!args.idw)
  }

  if (method == "kriging") {
    if (!inherits(vgm, "variogramModel")) {
      cli::cli_abort(
        "Please provide a {.fun gstat::vgm} output to {.arg vgm}. You have provided {.type {vgm}}."
      )
    }

    args.variogram <- append(
      args.variogram,
      list(
        object = stats::as.formula(paste(pollutant, 1, sep = "~")),
        locations = data_sf
      )
    )
    v <- rlang::exec(gstat::variogram, !!!args.variogram)

    args.fit.variogram <-
      append(
        args.fit.variogram,
        list(
          object = v,
          model = vgm
        )
      )
    v.m <- rlang::exec(gstat::fit.variogram, !!!args.fit.variogram)

    args.krige <-
      append(
        args.krige,
        list(
          formula = stats::as.formula(paste(pollutant, 1, sep = "~")),
          locations = data_sf,
          newdata = stars_grid,
          model = v.m
        )
      )
    interp <- rlang::exec(gstat::krige, !!!args.krige)
  }

  if (!is.null(breaks)) {
    if (is.null(labels)) {
      labels <- c()
      for (i in seq_along(breaks)) {
        if (is.na(breaks[i + 1])) {
          break
        }
        x <- paste(breaks[i], breaks[i + 1], sep = " - ")
        labels <- append(labels, x)
      }
    }

    interp$var1.pred <- cut(interp$var1.pred, breaks = breaks, labels = labels)
    data_sf[[pollutant]] <- cut(
      data_sf[[pollutant]],
      breaks = breaks,
      labels = labels
    )
  }

  if (static) {
    plot_fun <- make_static_interp_map
  } else {
    plot_fun <- make_dynamic_interp_map
  }

  map <-
    plot_fun(
      type = "rast",
      interp = interp,
      limits = limits,
      alpha = alpha,
      data_sf = data_sf,
      pollutant = pollutant,
      marker.border = marker.border,
      voronoi.border = NULL,
      provider = provider,
      cols = cols,
      legend = legend,
      legend.title = legend.title,
      legend.position = legend.position,
      legend.title.autotext = legend.title.autotext,
      show.markers = show.markers
    )

  return(map)
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
  static = FALSE,
  args.voronoi = list()
) {
  latlon <- assume_latlon(
    data,
    latitude = latitude,
    longitude = longitude,
    quiet = FALSE
  )
  latitude <- latlon$latitude
  longitude <- latlon$longitude

  data_sf <- prepare_sf_data(
    data = data,
    statistic = statistic,
    percentile = percentile,
    pollutant = pollutant,
    latitude = latitude,
    longitude = longitude,
    crs = crs
  )

  stars_grid <- create_interp_grid(data_sf = data_sf, newdata = newdata)

  args.voronoi <-
    append(
      args.voronoi,
      list(
        x = terra::vect(data_sf)
      )
    )

  interp <- rlang::exec(terra::voronoi, !!!args.voronoi) |>
    sf::st_as_sf() |>
    sf::st_intersection(sf::st_as_sf(stars_grid) |> dplyr::summarise())

  if (!is.null(breaks)) {
    if (is.null(labels)) {
      labels <- c()
      for (i in seq_along(breaks)) {
        if (is.na(breaks[i + 1])) {
          break
        }
        x <- paste(breaks[i], breaks[i + 1], sep = " - ")
        labels <- append(labels, x)
      }
    }

    interp[[pollutant]] <- cut(
      interp[[pollutant]],
      breaks = breaks,
      labels = labels
    )
    data_sf[[pollutant]] <- cut(
      data_sf[[pollutant]],
      breaks = breaks,
      labels = labels
    )
  }

  if (static) {
    plot_fun <- make_static_interp_map
  } else {
    plot_fun <- make_dynamic_interp_map
  }

  map <-
    plot_fun(
      type = "poly",
      interp = interp,
      limits = limits,
      alpha = alpha,
      data_sf = data_sf,
      pollutant = pollutant,
      marker.border = marker.border,
      voronoi.border = voronoi.border,
      provider = provider,
      cols = cols,
      legend = legend,
      legend.title = legend.title,
      legend.position = legend.position,
      legend.title.autotext = legend.title.autotext,
      show.markers = show.markers
    )

  return(map)
}

#' Get averages for each data
#' @noRd
prepare_sf_data <- function(
  data,
  statistic,
  percentile,
  pollutant,
  latitude,
  longitude,
  crs
) {
  if (percentile < 0 || percentile > 100) {
    cli::cli_abort("{.arg percentile} must be between {0L} and {100L}.")
  }
  percentile <- percentile / 100

  fun <- switch(
    statistic,
    "mean" = \(x) mean(x, na.rm = TRUE),
    "median" = \(x) stats::median(x, na.rm = TRUE),
    "max" = \(x) ifelse(all(is.na(x)), NA, max(x, na.rm = TRUE)),
    "min" = \(x) ifelse(all(is.na(x)), NA, min(x, na.rm = TRUE)),
    "sd" = \(x) ifelse(length(x) == 1, x, stats::sd(x, na.rm = TRUE)),
    "percentile" = \(x) stats::quantile(x, percentile, na.rm = TRUE)
  )

  data_sf <-
    data |>
    dplyr::summarise(
      "avg_pollutant" := fun(.data[[pollutant]]),
      .by = dplyr::all_of(c(latitude, longitude))
    ) |>
    stats::setNames(c(latitude, longitude, pollutant)) |>
    sf::st_as_sf(
      coords = c(longitude, latitude),
      crs = crs
    ) |>
    sf::st_transform(crs = 4326) |>
    tidyr::drop_na(dplyr::all_of(pollutant)) |>
    dplyr::filter(!is.infinite(.data[[pollutant]]))

  return(data_sf)
}

#' Create a grid over which to interpolate values
#' @noRd
create_interp_grid <- function(data_sf, newdata) {
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
  return(stars_grid)
}

#' Create ggplot2 map
#' @noRd
make_static_interp_map <- function(
  type = c("poly", "rast"),
  interp,
  limits,
  alpha,
  data_sf,
  pollutant,
  provider,
  marker.border,
  voronoi.border,
  cols,
  legend,
  legend.title,
  legend.position,
  legend.title.autotext,
  show.markers
) {
  map <- ggplot2::ggplot() +
    ggspatial::annotation_map_tile(zoomin = 0, cachedir = tempdir())

  if (type == "rast") {
    map <- map +
      stars::geom_stars(data = interp, alpha = alpha, show.legend = TRUE)
  } else {
    map <- map +
      ggplot2::geom_sf(
        data = interp,
        ggplot2::aes(fill = .data[[pollutant]]),
        alpha = alpha,
        color = voronoi.border,
        show.legend = TRUE
      )
  }

  if (show.markers) {
    map <- map +
      ggplot2::geom_sf(
        data = data_sf,
        ggplot2::aes(fill = .data[[pollutant]]),
        shape = 21,
        color = marker.border,
        show.legend = TRUE
      )
  }

  vec <-
    if (type == "rast") interp$var1.pred else interp[[pollutant]]

  if (inherits(vec, "factor")) {
    scale <-
      ggplot2::scale_fill_manual(
        values = openair::openColours(
          cols,
          n = length(levels(vec))
        ),
        na.value = NA,
        drop = FALSE,
        na.translate = F
      )
  } else {
    if (type == "rast") {
      vals <- limits %||%
        pretty(c(0, data_sf[[pollutant]], as.vector(interp$var1.pred)))
    } else {
      vals <- limits %||%
        pretty(c(0, data_sf[[pollutant]], interp[[pollutant]]))
    }

    scale <-
      ggplot2::scale_fill_gradientn(
        limits = range(vals),
        colors = openair::openColours(cols),
        na.value = NA
      )
  }

  map <- map +
    ggplot2::coord_sf(crs = 4326L) +
    scale +
    theme_static() +
    ggplot2::theme(
      legend.position = check_legendposition(legend.position, static = TRUE)
    ) +
    ggplot2::labs(
      x = NULL,
      y = NULL,
      fill = openair::quickText(
        legend.title %||% pollutant,
        auto.text = legend.title.autotext
      )
    )

  if (!legend) {
    map <- map + ggplot2::theme(legend.position = "none")
  }

  return(map)
}

#' Create leaflet map
#' @noRd
make_dynamic_interp_map <- function(
  type = c("poly", "rast"),
  interp,
  limits,
  alpha,
  data_sf,
  pollutant,
  provider,
  marker.border,
  voronoi.border,
  cols,
  legend,
  legend.title,
  legend.position,
  legend.title.autotext,
  show.markers
) {
  vec <-
    if (type == "rast") {
      interp$var1.pred
    } else {
      interp[[pollutant]]
    }

  if (inherits(vec, "factor")) {
    pal <-
      leaflet::colorFactor(
        palette = openair::openColours(cols, n = length(levels(vec))),
        levels = levels(vec),
        na.color = NA
      )
  } else {
    vals <- limits %||%
      pretty(c(0, data_sf[[pollutant]], as.vector(vec)))

    pal <-
      leaflet::colorNumeric(
        palette = openair::openColours(cols),
        domain = vals,
        na.color = NA
      )
  }

  map <-
    leaflet::leaflet() |>
    leaflet::addProviderTiles(provider = provider)

  if (type == "rast") {
    terra_interp <- terra::rast(interp)

    if (inherits(vec, "factor")) {
      cats_df <- terra::cats(terra_interp)[[1]]
      false_pal <-
        leaflet::colorFactor(
          palette = openair::openColours(cols, n = length(levels(vec))),
          domain = cats_df$value,
          na.color = NA
        )

      map <-
        leaflet::addRasterImage(
          map = map,
          x = terra_interp[[1]],
          opacity = alpha,
          colors = false_pal
        )
    } else {
      map <-
        leaflet::addRasterImage(
          map = map,
          x = terra_interp[[1]],
          opacity = alpha,
          colors = pal
        )
    }
  } else {
    map <-
      leaflet::addPolygons(
        map = map,
        data = interp,
        fillOpacity = alpha,
        opacity = alpha * 2,
        weight = 1,
        color = voronoi.border,
        fillColor = pal(interp[[pollutant]])
      )
  }

  if (show.markers) {
    map <-
      leaflet::addCircleMarkers(
        map = map,
        data = data_sf,
        fillColor = pal(data_sf[[pollutant]]),
        opacity = 1,
        fillOpacity = 1,
        weight = 2,
        color = marker.border,
        radius = 4
      )
  }

  if (legend) {
    if (inherits(vec, "factor")) {
      map <-
        leaflet::addLegend(
          map = map,
          labels = levels(vec),
          colors = pal(levels(vec)),
          title = ifelse(
            legend.title.autotext,
            quickTextHTML(legend.title %||% pollutant),
            legend.title %||% pollutant
          ),
          position = check_legendposition(legend.position, static = FALSE)
        )
    } else {
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
          position = check_legendposition(legend.position, static = FALSE)
        )
    }
  }

  return(map)
}
