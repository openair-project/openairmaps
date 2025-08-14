monthly_data <-
  openair::importUKAQ(
    source = "aurn",
    data_type = "monthly",
    year = 2020:2025,
    meta = TRUE
  )

type <- c("latitude", "longitude", "site")

models <-
  monthly_data |>
  tidyr::drop_na(all_of(pollutant)) |>
  dplyr::summarise(
    mod = list(lm(as.numeric(date) ~ pm10)$coefficients),
    .by = all_of(type)
  ) |>
  tidyr::unnest_wider(mod) |>
  dplyr::rename(intercept = `(Intercept)`) |>
  dplyr::mutate(
    pm10 = pm10 / (60 * 60 * 24 * 365)
  )

max_slope <- max(abs(models$pm10))
slope_range <- c(-max_slope, max_slope)

ggplot2::ggplot(models,ggplot2::aes(x = longitude, y = latitude, color = pm10)) +
  ggplot2::geom_point() +
  ggplot2::coord_sf()

plot_ellipsoid <- function(data) {
  data |>
    ggplot(aes(x, y)) +
    geom_polygon(aes(fill = t)) +
    coord_equal() +
    theme_void() +
    scale_fill_gradient2(
      low = "#2166AC",
      mid = "#F7F7F7",
      high = "#B2182B",
      limits = c(-1, 1),
      guide = guide_none()
    )
}

t <- tempdir()

ts$main.data |>
  dplyr::filter(site %in% ts$res2$site) |>
  ggplot(aes(group = site)) +
  geom_blank(aes(x = date, y = conc)) +
  geom_abline(aes(slope = b, intercept = a), color = "grey90") +
  geom_abline(
    data = ~ dplyr::filter(., site == unique(site)[100]),
    aes(slope = b, intercept = a),
    color = "blue",
    na.rm = TRUE
  ) +
  theme_classic() +
  labs(x = "Date", y = NULL)

purrr::walk(
  .x = seq_len(nrow(res2)),
  .f = \(x) {
    plt <- plot_ellipsoid(res2$data[[x]])
    ggsave(
      filename = res2$site[[x]],
      plot = plt,
      width = 3,
      height = 3,
      units = "in",
      device = "png",
      path = t
    )
  },
  .progress = TRUE
)

leaflet::leaflet(res2) |>
  leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatterNoLabels) |>
  leaflet::addMarkers(
    icon = ~ leaflet::makeIcon(
      iconUrl = paste0(t, "/", site),
      iconWidth = 20,
      iconHeight = 20,
      iconAnchorX = 10,
      iconAnchorY = 10
    )
  )

# Function to generate ellipsoid points based on transform value
generate_ellipsoid <- function(t, n_points = 100) {
  if (t < -1 || t > 1) {
    stop()
  }

  # Generate parameter values for the ellipse
  theta <- seq(0, 2 * pi, length.out = n_points)

  # Base ellipse parameters
  # Overall size scaling: larger as |t| approaches 1, smaller at t = 0
  size_scale <- 0.5 + 0.5 * abs(t) # size goes from 0.5 (at t=0) to 1.0 (at t=±1)

  if (abs(t) < 1e-6) {
    # Perfect circle when t ≈ 0, but scaled by size_scale
    a <- size_scale # semi-major axis
    b <- size_scale # semi-minor axis
    angle <- 0 # rotation angle
  } else {
    # As |t| approaches 1, one axis shrinks but retains some minimum width
    # The "fatness" decreases as we move away from 0, but never goes to 0
    min_width <- 0.05 # minimum width to prevent straight lines
    fatness <- (1 - abs(t)) * (1 - min_width) + min_width # fatness goes from 1 (at t=0) to min_width (at t=±1)

    # Overall size scaling: larger as |t| approaches 1, smaller at t = 0
    size_scale <- 0.5 + 0.5 * abs(t) # size goes from 0.5 (at t=0) to 1.0 (at t=±1)

    # Semi-axes: scaled by overall size
    a <- size_scale # major axis scales with |t|
    b <- fatness * size_scale # minor axis scales with both fatness and |t|

    # Rotation angle based on sign of t
    if (t > 0) {
      angle <- pi / 4 # 45° for bottom-left to top-right
    } else {
      angle <- -pi / 4 # -45° for top-left to bottom-right
    }
  }

  # Generate ellipse points
  x <- a * cos(theta)
  y <- b * sin(theta)

  # Apply rotation
  x_rot <- x * cos(angle) - y * sin(angle)
  y_rot <- x * sin(angle) + y * cos(angle)

  # Return as data frame
  data.frame(
    x = x_rot,
    y = y_rot,
    t = t
  )
}
