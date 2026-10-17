# Site average map engine ------------------------------------------------------
#
# `krigingMap()`, `voronoiMap()` and `pointMap()` all summarise the data at
# each site using `statistic`, and then colour the site markers and (optionally)
# an interpolated surface on one shared scale. This happens in two stages:
#
# 1. `interp_map_init()` - check inputs and summarise the data at each site.
# 2. `interp_map_draw()` - bin the colour scale and draw the map.
#
# Anything specific to one function (i.e., creating the interpolated surface)
# happens in that function between these stages.

#' Arguments shared by all site average `*Map()` functions
#'
#' `interp_map_init()` reads these from the calling function, so they don't
#' have to be passed through by hand. Every site average `*Map()` function must
#' have all of them as arguments - see `test-interp.R`.
#' @noRd
interp_map_args <- c(
  "pollutant",
  "statistic",
  "percentile",
  "breaks",
  "labels",
  "limits",
  "latitude",
  "longitude",
  "crs",
  "popup",
  "label",
  "provider",
  "cols",
  "alpha",
  "marker.border",
  "legend",
  "legend.position",
  "legend.title",
  "legend.title.autotext",
  "static",
  "api_key"
)

#' Start a site average map
#'
#' Collects the shared arguments (see `interp_map_args`) from the calling
#' function, checks them, and summarises the data at each site.
#' @param data The data.
#' @param env The calling function's environment.
#' @returns A list of settings, including the summarised data (`data_sf`), used
#'   by `interp_map_draw()`.
#' @noRd
interp_map_init <- function(data, env = rlang::caller_env()) {
  map <- rlang::env_get_list(env, interp_map_args)

  if (map$static) {
    rlang::check_installed(c("ggspatial", "prettymapr"))
  }

  map$provider <- check_providers(map$provider, map$static)
  map$legend.position <- check_legendposition(map$legend.position, map$static)

  latlon <- assume_latlon(
    data,
    latitude = map$latitude,
    longitude = map$longitude
  )

  map$data_sf <- prepare_sf_data(
    data = data,
    statistic = map$statistic,
    percentile = map$percentile,
    pollutant = map$pollutant,
    latitude = latlon$latitude,
    longitude = latlon$longitude,
    crs = map$crs,
    call = env
  )

  if (!is.null(map$popup) || !is.null(map$label)) {
    map <- add_site_popups(
      map,
      data = data,
      latitude = latlon$latitude,
      longitude = latlon$longitude,
      call = env
    )
  }

  map
}

#' Add popups and labels to the site averages
#'
#' The `popup` and `label` columns must have a single value per site. If either
#' names the pollutant, the site statistic (i.e., what the markers are coloured
#' by) is shown, rather than the raw data. Multiple `popup` columns are combined
#' using `buildPopup()`.
#' @returns `map`, with `.popup` and/or `.label` columns added to `data_sf`, and
#'   `popup`/`label` updated to match.
#' @noRd
add_site_popups <- function(map, data, latitude, longitude, call) {
  pollutant <- map$pollutant
  coords <- c(latitude, longitude)

  # swap the raw pollutant data for the (rounded) site statistic
  site_stat <- sf::st_drop_geometry(map$data_sf)[c(coords, pollutant)]
  site_stat[[pollutant]] <- signif(site_stat[[pollutant]], 3)
  data[[pollutant]] <- NULL
  data <- dplyr::left_join(data, site_stat, by = coords)

  popup <- map$popup
  if (length(popup) > 1) {
    # describe the statistic, e.g., "nox (max)"
    stat <- map$statistic
    if (stat == "percentile") {
      stat <- paste(ordinal(map$percentile), "percentile")
    }
    names(popup) <- names(popup) %||% rep("", length(popup))
    is_pollutant <- popup == pollutant & names(popup) == ""
    names(popup)[is_pollutant] <- paste0(pollutant, " (", stat, ")")

    data <- quick_popup(
      data = data,
      popup = popup,
      latitude = latitude,
      longitude = longitude,
      control = NULL
    )
    popup <- "popup"
  }

  popups <-
    dplyr::tibble(
      !!latitude := data[[latitude]],
      !!longitude := data[[longitude]],
      .popup = if (!is.null(popup)) data[[popup]],
      .label = if (!is.null(map$label)) data[[map$label]]
    ) |>
    dplyr::distinct()

  if (anyDuplicated(popups[coords])) {
    abort_multiple_popups(call = call)
  }

  map$data_sf <- dplyr::left_join(map$data_sf, popups, by = coords)
  map$popup <- if (!is.null(popup)) ".popup"
  map$label <- if (!is.null(map$label)) ".label"
  map
}

#' Draw a site average map
#'
#' Bins the site averages (and `surface`) using `breaks`, if given, and draws
#' them on a dynamic or static map with a shared colour scale and legend.
#' @param surface Optionally, an interpolated surface with a column named after
#'   the pollutant: either a `stars` raster (e.g., from [krigingMap()]) or `sf`
#'   polygons (e.g., from [voronoiMap()]). If `NULL`, only the site markers are
#'   drawn, which are then made larger and use `alpha`.
#' @param show.markers Draw the site markers?
#' @param voronoi.border The border colour of any polygons in `surface`.
#' @noRd
interp_map_draw <- function(
  map,
  surface = NULL,
  show.markers = TRUE,
  voronoi.border = NA
) {
  pollutant <- map$pollutant

  # discretise the colour scale
  if (!is.null(map$breaks)) {
    labels <- map$labels %||%
      paste(utils::head(map$breaks, -1), map$breaks[-1], sep = " - ")
    bin <- \(x) cut(x, breaks = map$breaks, labels = labels)

    map$data_sf[[pollutant]] <- bin(map$data_sf[[pollutant]])
    if (!is.null(surface)) {
      surface[[pollutant]] <- bin(surface[[pollutant]])
    }
  }

  # work out the colour scale, shared by the markers and surface
  if (is.factor(map$data_sf[[pollutant]])) {
    map$levels <- levels(map$data_sf[[pollutant]])
  } else {
    values <- map$data_sf[[pollutant]]
    if (!is.null(surface)) {
      values <- c(values, as.vector(surface[[pollutant]]))
    }
    map$range <- range(map$limits %||% pretty(c(0, values)))
  }

  map$title <- create_legend_title(
    static = map$static,
    legend.title.autotext = map$legend.title.autotext,
    legend.title = map$legend.title,
    str = pollutant
  )

  # without a surface, the markers are the main feature of the map
  map$marker.scale <- if (is.null(surface)) 2 else 1
  map$marker.alpha <- if (is.null(surface)) map$alpha else 1

  draw <- if (map$static) draw_static_interp_map else draw_dynamic_interp_map
  draw(
    map,
    surface = surface,
    show.markers = show.markers,
    voronoi.border = voronoi.border
  )
}

#' Create leaflet map
#' @noRd
draw_dynamic_interp_map <- function(
  map,
  surface,
  show.markers,
  voronoi.border
) {
  pollutant <- map$pollutant
  data_sf <- map$data_sf
  discrete <- !is.null(map$levels)

  if (discrete) {
    colours <- openair::openColours(map$cols, n = length(map$levels))
    pal <- leaflet::colorFactor(colours, levels = map$levels, na.color = NA)
  } else {
    pal <- leaflet::colorNumeric(
      palette = openair::openColours(map$cols),
      domain = map$range,
      na.color = NA
    )
  }

  out <-
    leaflet::leaflet() |>
    add_basemaps(map$provider)

  if (inherits(surface, "stars")) {
    raster <- terra::rast(surface)
    raster_pal <- pal
    if (discrete) {
      # categorical rasters are coloured by their integer codes
      raster_pal <- leaflet::colorFactor(
        colours,
        domain = terra::cats(raster)[[1]]$value,
        na.color = NA
      )
    }
    out <- leaflet::addRasterImage(
      map = out,
      x = raster[[1]],
      opacity = map$alpha,
      colors = raster_pal
    )
  } else if (inherits(surface, "sf")) {
    out <- leaflet::addPolygons(
      map = out,
      data = surface,
      fillOpacity = map$alpha,
      opacity = map$alpha * 2,
      weight = 1,
      color = voronoi.border,
      fillColor = pal(surface[[pollutant]])
    )
  }

  if (show.markers) {
    out <- leaflet::addCircleMarkers(
      map = out,
      data = data_sf,
      fillColor = pal(data_sf[[pollutant]]),
      opacity = map$marker.alpha,
      fillOpacity = map$marker.alpha,
      weight = 2,
      color = map$marker.border,
      radius = 4 * map$marker.scale,
      popup = if (!is.null(map$popup)) data_sf[[map$popup]],
      label = if (!is.null(map$label)) data_sf[[map$label]]
    )
  }

  if (map$legend) {
    if (discrete) {
      out <- leaflet::addLegend(
        map = out,
        labels = map$levels,
        colors = pal(map$levels),
        title = map$title,
        position = map$legend.position
      )
    } else {
      out <- leaflet::addLegend(
        map = out,
        pal = pal,
        values = map$range,
        title = map$title,
        position = map$legend.position
      )
    }
  }

  # allow switching between multiple basemaps
  add_layer_control(out, provider = map$provider)
}

#' Create ggplot2 map
#' @noRd
draw_static_interp_map <- function(
  map,
  surface,
  show.markers,
  voronoi.border
) {
  pollutant <- map$pollutant

  out <- ggplot2::ggplot() +
    ggspatial::annotation_map_tile(
      type = map$provider,
      zoomin = 0,
      cachedir = tempdir(),
      progress = "none",
      api_key = map$api_key
    )

  if (inherits(surface, "stars")) {
    out <- out +
      stars::geom_stars(data = surface, alpha = map$alpha, show.legend = TRUE)
  } else if (inherits(surface, "sf")) {
    out <- out +
      ggplot2::geom_sf(
        data = surface,
        ggplot2::aes(fill = .data[[pollutant]]),
        alpha = map$alpha,
        color = voronoi.border,
        show.legend = TRUE
      )
  }

  if (show.markers) {
    out <- out +
      ggplot2::geom_sf(
        data = map$data_sf,
        ggplot2::aes(fill = .data[[pollutant]]),
        shape = 21,
        size = 1.5 * map$marker.scale,
        alpha = map$marker.alpha,
        color = map$marker.border,
        show.legend = TRUE
      )
  }

  if (!is.null(map$levels)) {
    scale <- ggplot2::scale_fill_manual(
      values = openair::openColours(map$cols, n = length(map$levels)),
      na.value = NA,
      drop = FALSE,
      na.translate = FALSE
    )
  } else {
    scale <- ggplot2::scale_fill_gradientn(
      limits = map$range,
      colors = openair::openColours(map$cols),
      na.value = NA
    )
  }

  # without a surface, pad the map around the markers
  coords <- ggplot2::coord_sf(crs = 4326L)
  if (is.null(surface)) {
    bbox <- estimate_bbox(map$data_sf)
    coords <- ggplot2::coord_sf(
      crs = 4326L,
      xlim = c(bbox$xmin, bbox$xmax),
      ylim = c(bbox$ymin, bbox$ymax)
    )
  }

  out +
    coords +
    scale +
    theme_static() +
    ggplot2::theme(
      legend.position = if (map$legend) map$legend.position else "none"
    ) +
    ggplot2::labs(x = NULL, y = NULL, fill = map$title)
}

#' Get averages for each site
#'
#' The original `latitude` and `longitude` columns are kept, so other
#' information about each site (e.g., popups) can be joined on.
#' @noRd
prepare_sf_data <- function(
  data,
  statistic,
  percentile,
  pollutant,
  latitude,
  longitude,
  crs,
  call = rlang::caller_env()
) {
  statistic <- rlang::arg_match(
    statistic,
    c("mean", "median", "max", "min", "sd", "percentile"),
    error_call = call
  )

  if (percentile < 0 || percentile > 100) {
    cli::cli_abort(
      "{.arg percentile} must be between {0L} and {100L}.",
      call = call
    )
  }
  percentile <- percentile / 100

  fun <- switch(
    statistic,
    "mean" = \(x) mean(x, na.rm = TRUE),
    "median" = \(x) stats::median(x, na.rm = TRUE),
    "max" = \(x) ifelse(all(is.na(x)), NA, max(x, na.rm = TRUE)),
    "min" = \(x) ifelse(all(is.na(x)), NA, min(x, na.rm = TRUE)),
    "sd" = \(x) stats::sd(x, na.rm = TRUE),
    "percentile" = \(x) stats::quantile(x, percentile, na.rm = TRUE)
  )

  data_sf <-
    data |>
    dplyr::summarise(
      "{pollutant}" := fun(.data[[pollutant]]),
      .by = dplyr::all_of(c(latitude, longitude))
    ) |>
    sf::st_as_sf(
      coords = c(longitude, latitude),
      crs = crs,
      remove = FALSE
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
