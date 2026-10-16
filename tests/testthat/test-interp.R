skip_if_not_installed("terra")
skip_if_not_installed("stars")

# a few made-up sites with a simple gradient
interp_data <- tidyr::crossing(
  site = 1:6,
  rep = 1:3
) |>
  dplyr::mutate(
    lat = 51 + (.data$site %% 3) / 2,
    lon = -1 + (.data$site %/% 3) / 2,
    nox = .data$site * 10 + .data$rep
  )

# the default interpolation grid is fine (255 x 255), which is slow to draw -
# use a coarse one instead when testing the maps
local_coarse_grid <- function(env = parent.frame()) {
  local_mocked_bindings(
    create_interp_grid = function(data_sf, newdata) {
      stars::st_as_stars(sf::st_bbox(data_sf), nx = 10, ny = 10)
    },
    .env = env
  )
}

test_that("prepare_sf_data() summarises each site", {
  get_stat <- function(statistic, ...) {
    out <- prepare_sf_data(
      interp_data,
      statistic,
      percentile = 50,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      crs = 4326,
      ...
    )
    sort(out$nox)
  }
  expect_s3_class(
    prepare_sf_data(interp_data, "mean", 50, "nox", "lat", "lon", 4326),
    "sf"
  )
  expect_equal(get_stat("mean"), seq(12, 62, 10))
  expect_equal(get_stat("median"), seq(12, 62, 10))
  expect_equal(get_stat("max"), seq(13, 63, 10))
  expect_equal(get_stat("min"), seq(11, 61, 10))
  expect_equal(get_stat("sd"), rep(1, 6))
  expect_equal(unname(get_stat("percentile")), seq(12, 62, 10))
})

test_that("prepare_sf_data() handles missing data and single measurements", {
  data <- dplyr::filter(interp_data, .data$site != 1 | .data$rep == 1)
  data$nox[data$site == 2] <- NA

  out <- prepare_sf_data(data, "sd", 50, "nox", "lat", "lon", 4326)
  expect_equal(nrow(out), 4)

  out <- prepare_sf_data(data, "max", 50, "nox", "lat", "lon", 4326)
  expect_equal(nrow(out), 5)
})

test_that("prepare_sf_data() checks its inputs", {
  expect_error(
    prepare_sf_data(interp_data, "maen", 50, "nox", "lat", "lon", 4326),
    "statistic"
  )
  expect_error(
    prepare_sf_data(interp_data, "mean", 101, "nox", "lat", "lon", 4326),
    "percentile"
  )
})

test_that("create_interp_grid() covers the data or newdata", {
  data_sf <- prepare_sf_data(interp_data, "mean", 50, "nox", "lat", "lon", 4326)
  grid <- create_interp_grid(data_sf, NULL)
  expect_s3_class(grid, "stars")

  poly <- sf::st_as_sfc(sf::st_bbox(
    c(xmin = -2, xmax = 2, ymin = 50, ymax = 53),
    crs = 4326
  ))
  grid <- create_interp_grid(data_sf, sf::st_sf(geometry = poly))
  expect_equal(unname(sf::st_bbox(grid)[c("xmin", "ymax")]), c(-2, 53))
})

test_that("voronoiMap() makes dynamic maps", {
  local_coarse_grid()
  map <- quietly(voronoiMap(interp_data, "nox"))
  expect_s3_class(map, "leaflet")
  expect_length(leaflet_calls(map, "addPolygons"), 1)
  expect_length(leaflet_calls(map, "addCircleMarkers"), 1)
  expect_equal(leaflet_legends(map)[[1]]$title, "NO<sub>x</sub>")

  map <- quietly(voronoiMap(
    interp_data,
    "nox",
    breaks = c(0, 30, 70),
    show.markers = FALSE,
    legend.title = "my legend",
    provider = c("OpenStreetMap", "cartolight")
  ))
  expect_length(leaflet_calls(map, "addCircleMarkers"), 0)
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "my legend")
  expect_equal(as.character(legend$labels), c("0 - 30", "30 - 70"))
  expect_equal(layer_control(map)$base, c("OpenStreetMap", "CartoDB.Positron"))

  map <- quietly(voronoiMap(
    interp_data,
    "nox",
    breaks = c(0, 30, 70),
    labels = c("low", "high"),
    legend = FALSE
  ))
  expect_length(leaflet_legends(map), 0)
})

test_that("voronoiMap() makes static maps", {
  local_coarse_grid()
  skip_if_not_installed("ggspatial")
  skip_if_not_installed("prettymapr")
  map <- quietly(voronoiMap(
    interp_data,
    "nox",
    static = TRUE,
    provider = "CartoDB.Positron",
    legend.position = "bottom"
  ))
  expect_s3_class(map, "ggplot")
  expect_equal(map$layers[[1]]$data$type, "cartolight")
  expect_equal(map$theme$legend.position, "bottom")

  map <- quietly(voronoiMap(
    interp_data,
    "nox",
    breaks = c(0, 30, 70),
    static = TRUE,
    legend = FALSE,
    show.markers = FALSE
  ))
  expect_equal(map$theme$legend.position, "none")
  # (basemap tiles, a blank layer, voronoi polygons - no markers)
  expect_length(map$layers, 3)
})

test_that("raster interpolations can be mapped", {
  # krigingMap() returns a stars raster - this tests mapping one without
  # needing gstat
  data_sf <- prepare_sf_data(interp_data, "mean", 50, "nox", "lat", "lon", 4326)
  interp <- stars::st_as_stars(sf::st_bbox(data_sf), nx = 5, ny = 5)
  interp$var1.pred <- seq(10, 70, length.out = 25)

  args <- list(
    type = "rast",
    interp = interp,
    limits = NULL,
    alpha = 0.5,
    data_sf = data_sf,
    pollutant = "nox",
    provider = "OpenStreetMap",
    marker.border = "white",
    voronoi.border = NULL,
    cols = "turbo",
    legend = TRUE,
    legend.title = NULL,
    legend.position = NULL,
    legend.title.autotext = TRUE,
    api_key = NULL,
    show.markers = TRUE
  )

  map <- quietly(rlang::exec(make_dynamic_interp_map, !!!args))
  expect_length(leaflet_calls(map, "addRasterImage"), 1)
  expect_length(leaflet_legends(map), 1)

  # binned values
  binned <- interp
  binned$var1.pred <- cut(interp$var1.pred, c(0, 40, 80), c("lo", "hi"))
  data_binned <- data_sf
  data_binned$nox <- cut(data_sf$nox, c(0, 40, 80), c("lo", "hi"))
  args_binned <- utils::modifyList(
    args,
    list(interp = binned, data_sf = data_binned)
  )
  map <- quietly(rlang::exec(make_dynamic_interp_map, !!!args_binned))
  expect_equal(as.character(leaflet_legends(map)[[1]]$labels), c("lo", "hi"))

  skip_if_not_installed("ggspatial")
  args$provider <- args_binned$provider <- "osm"
  map <- quietly(rlang::exec(make_static_interp_map, !!!args))
  expect_s3_class(map, "ggplot")
  map <- quietly(rlang::exec(make_static_interp_map, !!!args_binned))
  expect_s3_class(map, "ggplot")
})

test_that("krigingMap() makes maps", {
  local_coarse_grid()
  skip_if_not_installed("gstat")
  map <- quietly(krigingMap(interp_data, "nox"))
  expect_s3_class(map, "leaflet")

  map <- quietly(krigingMap(
    interp_data,
    "nox",
    method = "idw",
    breaks = c(0, 30, 70)
  ))
  expect_s3_class(map, "leaflet")

  skip_if_not_installed("ggspatial")
  map <- quietly(krigingMap(interp_data, "nox", static = TRUE))
  expect_s3_class(map, "ggplot")

  expect_error(
    krigingMap(interp_data, "nox", method = "kriging", vgm = "foo"),
    "vgm"
  )
})
