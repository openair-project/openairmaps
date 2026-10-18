# Site average map engine ------------------------------------------------------
#
# `krigingMap()`, `voronoiMap()` and `pointMap()` all summarise the data at
# each site using `statistic`, and then colour the site markers and (optionally)
# an interpolated surface on one shared scale. This happens in two stages:
#
# 1. `interp_map_init()` - check inputs and summarise the data at each site.
# 2. `interp_map_draw()` - create any surfaces, bin the colour scale and draw
#    the map.
#
# Anything specific to one function (i.e., how to create the interpolated
# surface) is passed to `interp_map_draw()` as a function.
#
# When `type` is used, each `type` level is summarised (and interpolated)
# separately, and becomes a layer of a dynamic map or a panel of a static map.

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
  "type",
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
  "control.collapsed",
  "control.position",
  "control.autotext",
  "static",
  "static.nrow",
  "api_key"
)

#' Start a site average map
#'
#' Collects the shared arguments (see `interp_map_args`) from the calling
#' function, checks them, conditions the data by `type`, and summarises the data
#' at each site.
#' @param data The data.
#' @param ... The `...` of the calling function, passed to [openair::cutData()].
#' @param env The calling function's environment.
#' @returns A list of settings, including the summarised data (`data_sf`) and
#'   the column which splits it into layers/panels (`split_col`), used by
#'   `interp_map_draw()`.
#' @noRd
interp_map_init <- function(data, ..., env = rlang::caller_env()) {
  map <- rlang::env_get_list(env, interp_map_args)
  check_pollutant(map$pollutant, call = env)
  if (length(map$pollutant) > 1) {
    cli::cli_abort(
      c(
        "x" = "Only a single {.arg pollutant} can be mapped at once.",
        "i" = "You have provided {length(map$pollutant)}: {.field {map$pollutant}}."
      ),
      call = env
    )
  }

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

  # condition the data - without `type`, everything is in one layer
  if (length(map$type) > 1) {
    cli::cli_abort("{.arg type} must be a single value.", call = env)
  }
  if (is.null(map$type)) {
    map$split_col <- ".type"
    data$.type <- "all"
  } else {
    map$split_col <- map$type
    data <- openair::cutData(data, type = map$type, ...)
  }
  data[[map$split_col]] <- droplevels(as.factor(data[[map$split_col]]))

  missing <- setdiff(c(map$pollutant, map$popup, map$label), names(data))
  if (length(missing) > 0) {
    cli::cli_abort(
      "Can't find the variable{?s} {.field {missing}} in {.arg data}.",
      call = env
    )
  }

  map$data_sf <- prepare_sf_data(
    data = data,
    statistic = map$statistic,
    percentile = map$percentile,
    pollutant = map$pollutant,
    latitude = latlon$latitude,
    longitude = latlon$longitude,
    crs = map$crs,
    by = map$split_col,
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
#' Non-numeric `popup` and `label` columns must have a single value per site
#' (and `type` level). If either names the pollutant, the site statistic (i.e.,
#' what the markers are coloured by) is shown, rather than the raw data. Other
#' numeric columns are averaged. Multiple `popup` columns, or any numeric ones,
#' are combined using `buildPopup()`.
#' @returns `map`, with `.popup` and/or `.label` columns added to `data_sf`, and
#'   `popup`/`label` updated to match.
#' @noRd
add_site_popups <- function(map, data, latitude, longitude, call) {
  pollutant <- map$pollutant
  keys <- c(latitude, longitude, map$split_col)

  # swap the raw pollutant data for the (rounded) site statistic
  site_stat <- sf::st_drop_geometry(map$data_sf)[c(keys, pollutant)]
  site_stat[[pollutant]] <- signif(site_stat[[pollutant]], 3)
  data[[pollutant]] <- NULL
  data <- dplyr::left_join(data, site_stat, by = keys)

  popup <- map$popup
  # numeric columns go through buildPopup() - other columns have many values per
  # site so must be averaged, and leaflet won't show a bare number as a popup
  is_numeric <- purrr::map_lgl(popup, \(x) is.numeric(data[[x]]))
  if (length(popup) > 1 || any(is_numeric)) {
    # describe the statistic, e.g., "nox (max)"
    stat <- map$statistic
    if (stat == "percentile") {
      stat <- paste(ordinal(map$percentile), "percentile")
    }
    names(popup) <- names(popup) %||% rep("", length(popup))
    is_pollutant <- popup == pollutant & names(popup) == ""
    names(popup)[is_pollutant] <- paste0(pollutant, " (", stat, ")")
    # any other numeric columns are averaged
    popup <- label_mean_popups(popup, data, latitude, longitude)

    data <- quick_popup(
      data = data,
      popup = popup,
      latitude = latitude,
      longitude = longitude,
      control = map$type
    )
    popup <- ".popup"
  }

  # other numeric labels are averaged too
  label <- map$label
  if (!is.null(label) && label != pollutant && is.numeric(data[[label]])) {
    data <- dplyr::mutate(
      data,
      .label_mean = signif(mean(.data[[label]], na.rm = TRUE), 3),
      .by = dplyr::all_of(keys)
    )
    label <- ".label_mean"
  }

  popups <-
    dplyr::tibble(
      !!latitude := data[[latitude]],
      !!longitude := data[[longitude]],
      !!map$split_col := data[[map$split_col]],
      .popup = if (!is.null(popup)) data[[popup]],
      .label = if (!is.null(label)) data[[label]]
    ) |>
    dplyr::distinct()

  if (anyDuplicated(popups[keys])) {
    abort_multiple_popups(
      by = c("latitude", "longitude", if (!is.null(map$type)) "type"),
      call = call
    )
  }

  map$data_sf <- dplyr::left_join(map$data_sf, popups, by = keys)
  map$popup <- if (!is.null(popup)) ".popup"
  map$label <- if (!is.null(map$label)) ".label"
  map
}

#' Draw a site average map
#'
#' Creates a surface for each `type` level (if `surface_fun` is given), bins
#' the site averages and surfaces using `breaks` (if given), and draws them on a
#' dynamic or static map with a shared colour scale and legend.
#' @param surface_fun Optionally, a function which takes the site averages of a
#'   single `type` level (an `sf` data frame) and returns an interpolated
#'   surface with a column named after the pollutant: either a `stars` raster
#'   (e.g., in [krigingMap()]) or `sf` polygons (e.g., in [voronoiMap()]). If
#'   `NULL`, only the site markers are drawn, which are then made larger and use
#'   `alpha`.
#' @param show.markers Draw the site markers?
#' @param voronoi.border The border colour of any polygons in the surfaces.
#' @noRd
interp_map_draw <- function(
    map,
    surface_fun = NULL,
    show.markers = TRUE,
  voronoi.border = NA
) {
  pollutant <- map$pollutant

  # one surface per layer/panel
  map$groups <- levels(droplevels(map$data_sf[[map$split_col]]))
  surfaces <- NULL
  if (!is.null(surface_fun)) {
    surfaces <- lapply(map$groups, \(group) {
      surface_fun(map$data_sf[map$data_sf[[map$split_col]] == group, ])
    })
    names(surfaces) <- map$groups
  }

  # discretise the colour scale
  if (!is.null(map$breaks)) {
    breaks <- expand_breaks(
      map$breaks,
      values = c(
        map$data_sf[[pollutant]],
        unlist(lapply(surfaces, \(x) as.vector(x[[pollutant]])))
      )
    )
    labels <- map$labels %||%
      paste(
        utils::head(attr(breaks, "labels"), -1),
        attr(breaks, "labels")[-1],
        sep = " - "
      )
    bin <- \(x) {
      cut(x, breaks = breaks, labels = labels, include.lowest = TRUE)
    }

    map$data_sf[[pollutant]] <- bin(map$data_sf[[pollutant]])
    for (group in names(surfaces)) {
      surfaces[[group]][[pollutant]] <- bin(surfaces[[group]][[pollutant]])
    }
  }

  # work out the colour scale, shared by all markers and surfaces
  if (is.factor(map$data_sf[[pollutant]])) {
    map$levels <- levels(map$data_sf[[pollutant]])
  } else {
    values <- c(
      map$data_sf[[pollutant]],
      unlist(lapply(surfaces, \(x) as.vector(x[[pollutant]])))
    )
    map$range <- range(map$limits %||% pretty(c(0, values)))

    # values outside `limits` take the nearest colour (as in openair), rather
    # than being left uncoloured
    squish <- \(x) pmin(pmax(x, map$range[[1]]), map$range[[2]])
    map$data_sf[[pollutant]] <- squish(map$data_sf[[pollutant]])
    for (group in names(surfaces)) {
      surfaces[[group]][[pollutant]] <- squish(surfaces[[group]][[pollutant]])
    }
  }

  map$title <- create_legend_title(
    static = map$static,
    legend.title.autotext = map$legend.title.autotext,
    legend.title = map$legend.title,
    str = pollutant
  )

  # without a surface, the markers are the main feature of the map
  map$marker.scale <- if (is.null(surfaces)) 2 else 1
  map$marker.alpha <- if (is.null(surfaces)) map$alpha else 1

  draw <- if (map$static) draw_static_interp_map else draw_dynamic_interp_map
  draw(
    map,
    surfaces = surfaces,
    show.markers = show.markers,
    voronoi.border = voronoi.border
  )
}

#' Expand `breaks` to cover the data
#'
#' The outermost breaks are moved out to the range of `values`, if needed, so
#' that no values are left out of the colour scale. For example, `c(50, 100,
#' 150)` would become `c(25, 100, 200)` for values ranging from 25 to 200.
#' @returns `breaks`, with a `"labels"` attribute giving the breaks to show in
#'   default labels. Any expanded breaks are rounded to 3 significant figures,
#'   which the breaks themselves aren't, so no values fall outside them.
#' @noRd
expand_breaks <- function(breaks, values) {
  labels <- breaks
  values <- values[is.finite(values)]

  if (length(values) > 0 && length(breaks) > 1) {
    n <- length(breaks)
    if (min(values) < breaks[[1]]) {
      breaks[[1]] <- min(values)
      labels[[1]] <- signif(min(values), 3)
    }
    if (max(values) > breaks[[n]]) {
      breaks[[n]] <- max(values)
      labels[[n]] <- signif(max(values), 3)
    }
  }

  structure(breaks, labels = labels)
}

#' Create leaflet map
#' @noRd
draw_dynamic_interp_map <- function(
  map,
  surfaces,
  show.markers,
  voronoi.border
) {
  pollutant <- map$pollutant
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

  # `type` levels become layers
  textfun <- if (map$control.autotext) quickTextHTML else identity
  layer <- \(group) if (!is.null(map$type)) textfun(group)

  out <-
    leaflet::leaflet() |>
    add_basemaps(map$provider)

  for (group in map$groups) {
    surface <- surfaces[[group]]
    data_sf <- map$data_sf[map$data_sf[[map$split_col]] == group, ]

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
        colors = raster_pal,
        group = layer(group)
      )
    } else if (inherits(surface, "sf")) {
      out <- leaflet::addPolygons(
        map = out,
        data = surface,
        fillOpacity = map$alpha,
        opacity = map$alpha * 2,
        weight = 1,
        color = voronoi.border,
        fillColor = pal(surface[[pollutant]]),
        group = layer(group)
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
        label = if (!is.null(map$label)) data_sf[[map$label]],
        group = layer(group)
      )
    }
  }

  if (map$legend) {
    if (discrete) {
      out <- leaflet::addLegend(
        map = out,
        labels = map$levels,
        colors = pal(map$levels),
        title = map$title,
        opacity = map$alpha,
        position = map$legend.position
      )
    } else {
      out <- leaflet::addLegend(
        map = out,
        pal = pal,
        values = map$range,
        title = map$title,
        opacity = map$alpha,
        position = map$legend.position
      )
    }
  }

  # switch between `type` levels and/or multiple basemaps
  add_layer_control(
    out,
    provider = map$provider,
    groups = if (!is.null(map$type)) textfun(map$groups),
    position = map$control.position,
    collapsed = map$control.collapsed
  )
}

#' Create ggplot2 map
#' @noRd
draw_static_interp_map <- function(
  map,
  surfaces,
  show.markers,
  voronoi.border
) {
  pollutant <- map$pollutant
  split_col <- map$split_col

  # combine the surfaces into one layer, labelled by their panel
  combine <- function(to_df) {
    dplyr::bind_rows(lapply(names(surfaces), \(group) {
      df <- to_df(surfaces[[group]])
      df[[split_col]] <- factor(group, map$groups)
      df
    }))
  }

  out <- ggplot2::ggplot() +
    ggspatial::annotation_map_tile(
      type = map$provider,
      zoomin = 0,
      cachedir = tempdir(),
      progress = "none",
      api_key = map$api_key
    )

  if (inherits(surfaces[[1]], "stars")) {
    raster <- combine(as.data.frame)
    xy <- names(raster)[1:2]
    out <- out +
      ggplot2::geom_raster(
        data = raster,
        ggplot2::aes(
          x = .data[[xy[[1]]]],
          y = .data[[xy[[2]]]],
          fill = .data[[pollutant]]
        ),
        alpha = map$alpha,
        show.legend = TRUE
      )
  } else if (inherits(surfaces[[1]], "sf")) {
    out <- out +
      ggplot2::geom_sf(
        data = sf::st_as_sf(combine(identity)),
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
  if (is.null(surfaces)) {
    bbox <- estimate_bbox(map$data_sf)
    coords <- ggplot2::coord_sf(
      crs = 4326L,
      xlim = c(bbox$xmin, bbox$xmax),
      ylim = c(bbox$ymin, bbox$ymax)
    )
  }

  # `type` levels become panels
  if (!is.null(map$type)) {
    out <- out +
      ggplot2::facet_wrap(
        ggplot2::vars(.data[[split_col]]),
        nrow = map$static.nrow
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
#' @param by Other columns to summarise by (e.g., a `type` column).
#' @noRd
prepare_sf_data <- function(
  data,
  statistic,
  percentile,
  pollutant,
  latitude,
  longitude,
  crs,
  by = NULL,
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
      .by = dplyr::all_of(c(latitude, longitude, by))
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
    # the site data are always in lat/lng, so the grid must be too
    newdata <- sf::st_transform(newdata, crs = 4326)
    stars_grid <-
      sf::st_bbox(newdata) |>
      stars::st_as_stars(crs = 4326) |>
      sf::st_crop(newdata)
  }
  return(stars_grid)
}
