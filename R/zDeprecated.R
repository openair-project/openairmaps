#' Function for back-compatibility with the facet/control args
#' @param ... inherited from parent function
#' @noRd
check_facet_control <- function(control, ...) {
  dots <- rlang::list2(...)

  if ("control" %in% names(dots) || !is.null(control)) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.9.0",
      what = "polarMap(control)",
      with = "polarMap(type)",
      details = "This change has been made for better consistency with openair, and between dynamic and static maps."
    )
    if ("control" %in% names(dots)) {
      return(dots$control)
    } else {
      return(control)
    }
  }

  if ("facet" %in% names(dots)) {
    lifecycle::deprecate_warn(
      env = rlang::caller_env(),
      user_env = rlang::caller_env(2),
      when = "0.9.0",
      what = "polarMapStatic(facet)",
      with = "polarMap(type)",
      details = "This change has been made for better consistency with openair, and between dynamic and static maps. Note that static maps can now be produced using the 'static' argument of polarMap()"
    )
    return(dots$facet)
  }

  return(NULL)
}

#' Trajectory plots in `ggplot2`
#' @rdname deprecated-traj
#'
#' @description `r lifecycle::badge("deprecated")`
#'
#'   These functions existed at a time when [openair::trajPlot()] and
#'   [openair::trajLevel()] were written in `lattice`. Now they are written in
#'   `ggplot2`, these functions have been deprecated and are candidates for
#'   future removal.
#'
#' @inheritParams trajLevelMap
#' @inheritParams trajMapStatic
#' @param crs The coordinate reference system (CRS) into which all data should
#'   be projected before plotting. Defaults to latitude/longitude
#'   (`sf::st_crs(4326)`).
#' @param smooth Should the trajectory surface be smoothed? Defaults to `FALSE`.
#'   Note that smoothing may cause the plot to render slower, so consider
#'   setting `crs` to `sf::st_crs(4326)` or `NULL`.
#' @inheritDotParams ggplot2::coord_sf -xlim -ylim -crs -default_crs
#' @export
trajLevelMapStatic <-
  function(
    data,
    longitude = "lon",
    latitude = "lat",
    pollutant,
    type = NULL,
    smooth = FALSE,
    statistic = "frequency",
    percentile = 90,
    lon.inc = 1,
    lat.inc = 1,
    min.bin = 1,
    .combine = NULL,
    sigma = 1.5,
    alpha = 0.5,
    tile.border = NA,
    xlim = NULL,
    ylim = NULL,
    crs = sf::st_crs(4326),
    map = TRUE,
    map.fill = "grey85",
    map.colour = "grey75",
    map.alpha = 0.8,
    map.lwd = 0.5,
    map.lty = 1,
    facet = NULL,
    ...
  ) {
    rlang::check_installed("ggplot2")

    # handle deprecated argument
    if (!is.null(facet)) {
      lifecycle::deprecate_soft(
        when = "0.9.0",
        what = "trajLevelMapStatic(facet)",
        with = "trajLevelMapStatic(type)"
      )
    }
    type <- type %||% facet

    # prep data for running in TrajLevel
    if (statistic == "frequency") {
      title <- "percentage\ntrajectories"
      pollutant <- "default_pollutant"
      data[[pollutant]] <- pollutant
    }

    if (statistic == "difference") {
      lastnum <- stringr::str_sub(percentile, 2, 2)
      suff <- "th"
      if (lastnum == "1") {
        suff <- "st"
      }
      if (lastnum == "2") {
        suff <- "nd"
      }
      if (lastnum == "3") {
        suff <- "rd"
      }
      title <-
        stringr::str_glue(
          "gridded\ndifferences\n({percentile}{suff} percentile)"
        )
    }

    if (statistic == "pscf") {
      title <- "PSCF\nprobability"
    }
    if (statistic == "cwt") {
      title <- ""
    }
    if (statistic == "sqtba") {
      title <-
        openair::quickText(stringr::str_glue("SQTBA\n({pollutant})"))
    }

    # run openair::trajLevel()
    data <- openair::trajLevel(
      mydata = data,
      lon = longitude,
      lat = latitude,
      pollutant = pollutant,
      statistic = statistic,
      percentile = percentile,
      lat.inc = lat.inc,
      lon.inc = lon.inc,
      min.bin = min.bin,
      type = type %||% "default",
      .combine = .combine,
      sigma = sigma,
      plot = FALSE
    )$data

    # fix names
    names(data)[names(data) == "height"] <- pollutant

    # smooth
    if (smooth) {
      data <- smooth_trajgrid(data, pollutant)
    }

    # start plot
    plt <-
      ggplot2::ggplot(
        data,
        ggplot2::aes(
          x = .data$xgrid,
          y = .data$ygrid,
          fill = .data[[pollutant]]
        )
      )

    if (map) {
      world <- ggplot2::map_data("world")

      plt <- plt +
        ggplot2::geom_polygon(
          data = world,
          fill = map.fill,
          colour = map.colour,
          alpha = map.alpha,
          linewidth = map.lwd,
          lty = map.lty,
          ggplot2::aes(.data$long, .data$lat, group = .data$group)
        )
    }

    # predict x/ylims
    if (is.null(xlim)) {
      d_lon <-
        diff(range(c(min(data$xgrid), max(data$xgrid)))) * 0.1
      xlim <-
        c(min(data$xgrid) - d_lon, max(data$xgrid) + d_lon)
    }
    if (is.null(ylim)) {
      d_lat <-
        diff(range(c(min(data$ygrid), max(data$ygrid)))) * 0.1
      ylim <-
        c(min(data$ygrid) - d_lat, max(data$ygrid) + d_lat)
    }

    # create coordinate system
    if (!is.null(crs)) {
      coords <-
        ggplot2::coord_sf(
          xlim = xlim,
          ylim = ylim,
          default_crs = sf::st_crs(4326),
          crs = crs,
          ...
        )
    } else {
      coords <-
        ggplot2::coord_sf(
          xlim = xlim,
          ylim = ylim,
          ...
        )
    }

    # add to plot
    plt <- plt +
      ggplot2::geom_tile(alpha = alpha, color = tile.border) +
      theme_static() +
      ggplot2::labs(x = "longitude", y = "latitude", fill = title) +
      coords

    # deal with facets
    if (!is.null(type)) {
      plt <-
        plt + ggplot2::facet_wrap(ggplot2::vars(.data[[type]]))
    }

    # return plot
    return(plt)
  }

#' @rdname deprecated-traj
#'
#' @inheritParams trajMap
#'
#' @param colour *Data column to map to the colour of the trajectories.*
#'
#'  *default:* `NULL`
#'
#'   This column may be numeric, character, factor or date(time). This will
#'   commonly be a pollutant concentration which has been joined (e.g., by
#'   [dplyr::left_join()]) to the trajectory data by "date". The scale can be
#'   edited after the fact using [ggplot2::scale_color_continuous()] or similar.
#'
#' @param size,linewidth *Data column to map to the size/width of the trajectory
#'   marker/paths, or absolute size value.*
#'
#'  *default:* `NULL`
#'
#'   Similar to the `colour` argument, this defines a column to map to the size
#'   of the circular markers or the width of the paths. These scales can be
#'   edited after the fact using [ggplot2::scale_size_continuous()],
#'   [ggplot2::scale_linewidth_continuous()], or similar. If numeric, the value
#'   will be directly provided to `ggplot2::geom_point(size = )` or
#'   `ggplot2::geom_path(linewidth = )`.
#'
#' @param type *A method to condition the `data` for separate plotting.*
#'
#'  *default:* `NULL`
#'
#'   Used for splitting the trajectories into different groups which will appear
#'   as different panels. Passed to [openair::cutData()].
#'
#' @param group *Column to use to distinguish different trajectory paths.*
#'
#'  *default:* `NULL`
#'
#'   By default, trajectory paths are distinguished using the arrival date.
#'   `group` allows for additional columns to be used (e.g., `"receptor"` if
#'   multiple receptors are being plotted).
#'
#' @param xlim,ylim *The x- and y-limits of the plot.*
#'
#'  *default:* `NULL`
#'
#'   A numeric vector of length two defining the x-/y-limits of the map, passed
#'   to [ggplot2::coord_sf()]. If `NULL`, limits will be estimated based on the
#'   lat/lon ranges of the input data.
#'
#' @param crs *The coordinate reference system (CRS) into which all data should
#'   be projected before plotting.*
#'
#'   *default:* `sf::st_crs(3812)`
#'
#'   This argument defaults to the Lambert projection, but can take any
#'   coordinate reference system to pass to the `crs` argument of
#'   [ggplot2::coord_sf()]. Alternatively, `crs` can be set to `NULL`, which
#'   will typically render the map quicker but may cause countries far from the
#'   equator or large areas to appear distorted.
#'
#' @param map *Draw a base map?*
#'
#'  *default:* `TRUE`
#'
#'   Draws the geometries of countries under the trajectory paths.
#'
#' @param map.fill *Colour to use to fill the polygons of the base map.*
#'
#'  *default:* `"grey85"`
#'
#'   See `colors()` for colour options. Alternatively, a hexadecimal color code
#'   can be provided.
#'
#' @param map.colour *Colour to use for the polygon borders of the base map.*
#'
#'  *default:* `"grey75"`
#'
#'   See `colors()` for colour options. Alternatively, a hexadecimal color code
#'   can be provided.
#'
#' @param map.alpha *Transparency of the base map polygons.*
#'
#'  *default:* `0.8`
#'
#'   Must be between `0` (fully transparent) and `1` (fully opaque).
#'
#' @param map.lwd *Line width of the base map polygon borders.*
#'
#'  *default:* `0.5`
#'
#'   Any numeric value.
#'
#' @param map.lty *Line type of the base map polygon borders.*
#'
#'  *default:* `1`
#'
#'   See [ggplot2::scale_linetype()] for common examples. The default, `1`,
#'   draws solid lines.
#'
#' @param origin *Draw the receptor point as a circle?*
#'
#'  *default:* `TRUE`
#'
#'   When `TRUE`, the receptor point(s) are marked with black circles.
#'
#' @param facet Deprecated. Please use `type`.
#'
#' @inheritDotParams openair::cutData -x -type
#'
#' @export
trajMapStatic <-
  function(
    data,
    colour = "height",
    type = NULL,
    group = NULL,
    size = NULL,
    linewidth = size,
    longitude = "lon",
    latitude = "lat",
    npoints = 12,
    xlim = NULL,
    ylim = NULL,
    crs = sf::st_crs(3812),
    origin = TRUE,
    map = TRUE,
    map.fill = "grey85",
    map.colour = "grey75",
    map.alpha = 0.8,
    map.lwd = 0.5,
    map.lty = 1,
    facet = NULL,
    ...
  ) {
    rlang::check_installed("ggplot2")

    # handle deprecated argument
    if (!is.null(facet)) {
      lifecycle::deprecate_soft(
        when = "0.9.0",
        what = "trajMapStatic(facet)",
        with = "trajMapStatic(type)"
      )
    }
    type <- type %||% facet

    # create dummy group if no group given
    if (is.null(group)) {
      data$openairmaps_group <- "group"
      group <- "openairmaps_group"
    }

    # cut data
    type <- type %||% "default"
    data <- openair::cutData(x = data, type = type, ...)

    # make plot
    plt <-
      ggplot2::ggplot(
        data,
        ggplot2::aes(x = .data[[longitude]], y = .data[[latitude]])
      )

    if (map) {
      world <- ggplot2::map_data("world")

      plt <- plt +
        ggplot2::geom_polygon(
          data = world,
          fill = map.fill,
          colour = map.colour,
          alpha = map.alpha,
          linewidth = map.lwd,
          lty = map.lty,
          ggplot2::aes(.data$long, .data$lat, group = group)
        )
    }

    if (is.null(xlim)) {
      d_lon <-
        diff(range(c(min(data[[longitude]]), max(data[[longitude]])))) * 0.1
      xlim <-
        c(min(data[[longitude]]) - d_lon, max(data[[longitude]]) + d_lon)
    }
    if (is.null(ylim)) {
      d_lat <-
        diff(range(c(min(data[[latitude]]), max(data[[latitude]])))) * 0.1
      ylim <-
        c(min(data[[latitude]]) - d_lat, max(data[[latitude]]) + d_lat)
    }

    points_df <- dplyr::filter(data, .data$hour.inc %% npoints == 0)

    plt_aes <-
      ggplot2::aes(
        group = interaction(.data$date, .data[[group]]),
        color = .data[[colour]]
      )
    plt_aes_point <- plt_aes
    plt_aes_path <- plt_aes

    if (!is.null(linewidth)) {
      if (is.character(linewidth)) {
        plt_aes_path <-
          utils::modifyList(
            plt_aes_path,
            ggplot2::aes(linewidth = .data[[linewidth]])
          )
      }
    }

    if (!is.null(size)) {
      if (is.character(size)) {
        plt_aes_point <-
          utils::modifyList(plt_aes_point, ggplot2::aes(size = .data[[size]]))
      }
    }

    # create coordinate system
    if (!is.null(crs)) {
      coords <-
        ggplot2::coord_sf(
          xlim = xlim,
          ylim = ylim,
          default_crs = sf::st_crs(4326),
          crs = crs
        )
    } else {
      coords <-
        ggplot2::coord_sf(
          xlim = xlim,
          ylim = ylim
        )
    }

    ourGeomPoint <- ggplot2::geom_point
    if (!is.null(size)) {
      if (is.numeric(size)) {
        ourGeomPoint <- function(...) {
          ggplot2::geom_point(size = size, ...)
        }
      }
    }

    ourGeomPath <- ggplot2::geom_path
    if (!is.null(linewidth)) {
      if (is.numeric(linewidth)) {
        ourGeomPath <- function(...) {
          ggplot2::geom_path(linewidth = linewidth, ...)
        }
      }
    }

    for (i in unique(data$date)) {
      plt <-
        plt +
        ourGeomPath(
          data = dplyr::filter(data, date == i),
          mapping = plt_aes_path
        ) +
        ourGeomPoint(
          data = dplyr::filter(points_df, date == i),
          mapping = plt_aes_point
        )
    }

    plt <- plt + coords

    if (all(type != "default")) {
      plt <-
        plt + ggplot2::facet_wrap(ggplot2::vars(.data[[type]]))
    }

    if (origin) {
      plt <-
        plt +
        ggplot2::geom_point(
          data = dplyr::filter(data, .data$hour.inc == 0) |>
            dplyr::distinct(.data[[latitude]], .data[[longitude]]),
          size = 5,
          stroke = 1.5,
          shape = 21,
          color = "white",
          fill = "black"
        )
    }

    return(plt)
  }
