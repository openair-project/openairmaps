#' Title
#'
#' @param data
#' @param longitude
#' @param latitude
#' @param pollutant
#' @param statistic
#' @param percentile
#' @param min.bin
#' @param cols
#' @param alpha
#' @param provider
#' @param legend.position
#' @param legend.title
#' @param legend.title.autotext
#' @param show.ocean
#' @param map.scale
#'
#' @export
trajCountryMap <- function(
  data,
  longitude = "lon",
  latitude = "lat",
  pollutant = "height",
  statistic = c(
    "frequency",
    "mean",
    "max",
    "min",
    "median",
    "sd",
    "percentile"
  ),
  percentile = 90,
  min.bin = 1,
  show.ocean = c("average", "value", "none"),
  cols = "turbo",
  alpha = .75,
  map.scale = 50,
  provider = "OpenStreetMap",
  legend.position = "topright",
  legend.title = NULL,
  legend.title.autotext = TRUE
) {
  # validate inputs
  show.ocean <- rlang::arg_match(show.ocean)
  statistic <- rlang::arg_match(statistic)

  # don't use s2, but reset on exit
  x <- suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(x)))

  # turn trajectory into SF dataframe
  traj_sf <-
    data |>
    sf::st_as_sf(coords = c(longitude, latitude), crs = 4326, remove = FALSE)

  # import world data
  world <- rnaturalearth::ne_countries(scale = map.scale)

  # get the origin point for the trajectories
  origin_sf <-
    traj_sf |>
    dplyr::filter(.data$hour.inc == 0) |>
    dplyr::distinct(.data$geometry)
  origin_id <- as.numeric(sf::st_within(origin_sf, world))

  # assign countries to trajectory data
  id <- sf::st_within(traj_sf, world)
  id <- as.numeric(id)
  id[id == origin_id] <- NA
  traj_sf$sovereignt <- world$sovereignt[as.numeric(id)]

  # if all countries are missing for a given date, assign to be an 'Ocean' trajectory
  traj_sf <-
    traj_sf |>
    dplyr::mutate(
      ocean = all(is.na(.data$sovereignt)),
      .by = date
    ) |>
    dplyr::mutate(
      sovereignt = dplyr::if_else(.data$ocean, "Ocean", .data$sovereignt)
    )

  # statistic handling
  stat_fun <- switch(
    statistic,
    "frequency" = \(x) dplyr::n(),
    "mean" = \(x) mean(x, na.rm = TRUE),
    "max" = \(x) ifelse(all(is.na(x)), NA, max(x, na.rm = TRUE)),
    "min" = \(x) ifelse(all(is.na(x)), NA, min(x, na.rm = TRUE)),
    "median" = \(x) median(x, na.rm = TRUE),
    "sd" = \(x) sd(x, na.rm = TRUE),
    "percentile" = \(x) quantile(x, na.rm = TRUE, percentile / 100)
  )
  fun <- function(x) {
    if (length(x) >= min.bin) {
      stat_fun(x)
    } else {
      NA
    }
  }

  # if statistic is frequency, set pollutant to be "1"
  if (statistic == "frequency") {
    pollutant <- "count"
    traj_sf[[pollutant]] <- 1L
  }

  # get average per country
  avg_traj <- traj_sf |>
    sf::st_drop_geometry() |>
    dplyr::summarise(
      {{ pollutant }} := fun(.data[[pollutant]]),
      .by = "sovereignt"
    )

  # get traj_sf just over ocean
  traj_sf_ocean <- dplyr::filter(traj_sf, sovereignt == "Ocean")

  # if showing average ocean concs, overwrite pollutant w/ average value
  if (show.ocean == "average") {
    traj_sf_ocean <-
      dplyr::mutate(
        traj_sf_ocean,
        {{ pollutant }} := avg_traj[[pollutant]][
          avg_traj$sovereignt == "Ocean" &
            !is.na(avg_traj$sovereignt == "Ocean")
        ]
      )
  }

  # get lines
  traj_sf_ocean_lines <-
    traj_sf_ocean |>
    dplyr::group_by(.data$date, .data[[pollutant]]) |>
    dplyr::summarise(do_union = FALSE) |>
    sf::st_cast("LINESTRING")

  # create plot
  plot <-
    world |>
    dplyr::inner_join(avg_traj, by = dplyr::join_by("sovereignt")) |>
    ggplot2::ggplot() +
    ggspatial::annotation_map_tile(
      type = "osm",
      cachedir = tempdir(),
      zoomin = 0
    ) +
    ggplot2::geom_sf(alpha = alpha, ggplot2::aes(fill = .data[[pollutant]])) +
    theme_static() +
    ggplot2::scale_color_gradientn(
      colours = openair::openColours("turbo"),
      aesthetics = c("fill", "color")
    ) +
    ggplot2::labs(
      fill = openair::quickText(
        legend.title %||% pollutant,
        legend.title.autotext
      ),
      color = openair::quickText(
        legend.title %||% pollutant,
        legend.title.autotext
      ),
      x = NULL,
      y = NULL
    )

  if (show.ocean != "none") {
    plot <- plot +
      ggplot2::geom_sf(
        data = traj_sf_ocean_lines,
        ggplot2::aes(
          color = .data[[pollutant]],
          group = .data$date
        )
      ) +
      ggplot2::geom_sf(
        data = dplyr::filter(traj_sf_ocean, hour.inc %% 6 == 0),
        ggplot2::aes(color = .data[[pollutant]])
      )
  }

  plot <- plot +
    ggplot2::coord_sf(
      xlim = c(sf::st_bbox(traj_sf)[["xmin"]], sf::st_bbox(traj_sf)[["xmax"]]),
      ylim = c(sf::st_bbox(traj_sf)[["ymin"]], sf::st_bbox(traj_sf)[["ymax"]])
    )

  return(plot)
}
