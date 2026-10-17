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
    provider = c("Esri.WorldGrayCanvas", "hotstyle")
  ))
  expect_length(leaflet_calls(map, "addCircleMarkers"), 0)
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "my legend")
  expect_equal(as.character(legend$labels), c("0 - 30", "30 - 70"))
  expect_equal(
    layer_control(map)$base,
    c("Esri.WorldGrayCanvas", "OpenStreetMap.HOT")
  )

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
    provider = "OpenStreetMap",
    legend.position = "bottom"
  ))
  expect_s3_class(map, "ggplot")
  expect_equal(map$layers[[1]]$data$type, "osm")
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

# a stand-in for a site average *Map() function
fake_interp_map <- function(
  data,
  pollutant = "nox",
  statistic = "mean",
  percentile = 95,
  breaks = NULL,
  labels = NULL,
  limits = NULL,
  latitude = "lat",
  longitude = "lon",
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 0.5,
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
  surface = NULL
) {
  surface_fun <- if (!is.null(surface)) \(sites) surface
  interp_map_draw(interp_map_init(data), surface_fun = surface_fun)
}

test_that("site average maps have all of the shared arguments", {
  for (fun in list(krigingMap, voronoiMap, pointMap)) {
    expect_in(interp_map_args, names(formals(fun)))
  }
})

test_that("raster interpolations can be mapped", {
  # krigingMap() returns a stars raster - this tests mapping one without
  # needing gstat
  data_sf <- prepare_sf_data(interp_data, "mean", 50, "nox", "lat", "lon", 4326)
  surface <- stars::st_as_stars(sf::st_bbox(data_sf), nx = 5, ny = 5)
  names(surface) <- "nox"
  surface$nox <- seq(10, 70, length.out = 25)

  map <- quietly(fake_interp_map(interp_data, surface = surface))
  expect_length(leaflet_calls(map, "addRasterImage"), 1)
  expect_length(leaflet_legends(map), 1)

  # binned values
  map <- quietly(fake_interp_map(
    interp_data,
    surface = surface,
    breaks = c(0, 40, 80),
    labels = c("lo", "hi")
  ))
  expect_length(leaflet_calls(map, "addRasterImage"), 1)
  expect_equal(as.character(leaflet_legends(map)[[1]]$labels), c("lo", "hi"))

  skip_if_not_installed("ggspatial")
  skip_if_not_installed("prettymapr")
  map <- quietly(fake_interp_map(interp_data, surface = surface, static = TRUE))
  expect_s3_class(map, "ggplot")
  map <- quietly(fake_interp_map(
    interp_data,
    surface = surface,
    breaks = c(0, 40, 80),
    static = TRUE
  ))
  expect_s3_class(map, "ggplot")
})

test_that("pointMap() makes dynamic maps", {
  map <- quietly(pointMap(interp_data, "nox"))
  expect_s3_class(map, "leaflet")
  expect_length(leaflet_calls(map, "addPolygons"), 0)
  expect_length(leaflet_calls(map, "addRasterImage"), 0)

  markers <- leaflet_calls(map, "addCircleMarkers")
  expect_length(markers, 1)
  # one larger marker per site
  expect_length(markers[[1]]$args[[1]], 6)
  expect_equal(markers[[1]]$args[[3]], 8)
  expect_equal(leaflet_legends(map)[[1]]$title, "NO<sub>x</sub>")

  map <- quietly(pointMap(
    interp_data,
    "nox",
    statistic = "max",
    breaks = c(0, 30, 70),
    legend.title = "my legend"
  ))
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "my legend")
  expect_equal(as.character(legend$labels), c("0 - 30", "30 - 70"))

  expect_length(
    leaflet_legends(pointMap(interp_data, "nox", legend = FALSE)),
    0
  )
  expect_error(pointMap(interp_data, "nox", statistic = "maen"), "statistic")
  expect_error(pointMap(interp_data), "pollutant")
  expect_error(voronoiMap(interp_data), "pollutant")
})

test_that("site average maps can have popups and labels", {
  data <- dplyr::mutate(
    interp_data,
    name = paste("Site", .data$site),
    site_type = ifelse(.data$site < 4, "Urban", "Rural")
  )

  map <- quietly(pointMap(data, "nox", popup = "name", label = "site_type"))
  call <- leaflet_calls(map, "addCircleMarkers")[[1]]$args
  expect_setequal(call[[9]], paste("Site", 1:6))
  expect_setequal(call[[11]], c("Urban", "Rural"))

  # multiple columns are combined using buildPopup()
  map <- quietly(pointMap(data, "nox", popup = c("name", "site_type")))
  popups <- leaflet_calls(map, "addCircleMarkers")[[1]]$args[[9]]
  expect_length(popups, 6)
  expect_match(
    popups,
    "<b>Name</b>: Site [0-9]<br><b>Site Type</b>: (Urban|Rural)"
  )

  # popups must be unique per site
  expect_error(pointMap(data, "nox", popup = "rep"), "Multiple popups")

  # the pollutant shows the site statistic, not the mean of the raw data
  map <- quietly(pointMap(
    data,
    "nox",
    statistic = "max",
    popup = c("name", "nox"),
    label = "nox"
  ))
  call <- leaflet_calls(map, "addCircleMarkers")[[1]]$args
  expect_setequal(call[[11]], seq(13, 63, 10))
  expect_match(call[[9]], "<b>NO<sub>x</sub> \\(max\\)</b>: [1-6]3$")

  map <- quietly(pointMap(
    data,
    "nox",
    statistic = "percentile",
    percentile = 92,
    popup = c("name", "Concentration" = "nox")
  ))
  popups <- leaflet_calls(map, "addCircleMarkers")[[1]]$args[[9]]
  expect_match(popups, "<b>Concentration</b>")

  expect_equal(
    ordinal(c(1, 2, 3, 4, 11, 12, 13, 21, 92, 101, 111)),
    c(
      "1st",
      "2nd",
      "3rd",
      "4th",
      "11th",
      "12th",
      "13th",
      "21st",
      "92nd",
      "101st",
      "111th"
    )
  )

  map <- local({
    local_coarse_grid()
    quietly(voronoiMap(data, "nox", label = "name"))
  })
  call <- leaflet_calls(map, "addCircleMarkers")[[1]]$args
  expect_setequal(call[[11]], paste("Site", 1:6))
})

test_that("site average maps can be split using type", {
  data <- dplyr::mutate(
    interp_data,
    period = factor(
      ifelse(.data$rep == 1, "before", "after"),
      c("before", "after")
    )
  )

  # each level is summarised separately, and becomes a layer
  map <- quietly(pointMap(data, "nox", type = "period", label = "nox"))
  markers <- leaflet_calls(map, "addCircleMarkers")
  expect_length(markers, 2)
  expect_equal(vapply(markers, \(x) x$args[[5]], ""), c("before", "after"))
  expect_setequal(markers[[1]]$args[[11]], seq(11, 61, 10))
  expect_setequal(markers[[2]]$args[[11]], seq(12.5, 62.5, 10))
  expect_equal(layer_control(map)$base, c("before", "after"))
  # ...with one shared legend
  expect_length(leaflet_legends(map), 1)

  # popups need to be unique per site and level
  data$name <- paste("Site", data$site)
  expect_no_error(quietly(pointMap(
    data,
    "nox",
    type = "period",
    popup = "name"
  )))
  expect_error(
    pointMap(data, "nox", type = "period", popup = "rep"),
    "latitude/longitude/type"
  )

  map <- local({
    local_coarse_grid()
    quietly(voronoiMap(data, "nox", type = "period", control.autotext = FALSE))
  })
  polygons <- leaflet_calls(map, "addPolygons")
  expect_length(polygons, 2)
  expect_equal(vapply(polygons, \(x) x$args[[3]], ""), c("before", "after"))

  expect_error(pointMap(data, "nox", type = c("period", "site")), "single")

  skip_if_not_installed("ggspatial")
  skip_if_not_installed("prettymapr")
  map <- quietly(pointMap(data, "nox", type = "period", static = TRUE))
  expect_s3_class(map$facet, "FacetWrap")

  # static rasters are faceted too
  data_sf <- prepare_sf_data(interp_data, "mean", 50, "nox", "lat", "lon", 4326)
  surface <- stars::st_as_stars(sf::st_bbox(data_sf), nx = 5, ny = 5)
  names(surface) <- "nox"
  surface$nox <- seq(10, 70, length.out = 25)
  map <- quietly(fake_interp_map(
    data,
    type = "period",
    surface = surface,
    static = TRUE
  ))
  raster <- map$layers[[3]]$data
  expect_equal(levels(raster$period), c("before", "after"))
  expect_equal(nrow(raster), 50)
})

test_that("pointMap() makes static maps", {
  skip_if_not_installed("ggspatial")
  skip_if_not_installed("prettymapr")
  map <- quietly(pointMap(
    interp_data,
    "nox",
    static = TRUE,
    legend.position = "bottom"
  ))
  expect_s3_class(map, "ggplot")
  expect_equal(map$theme$legend.position, "bottom")
  # the map is padded around the markers
  expect_lt(map$coordinates$limits$x[[1]], min(interp_data$lon))
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
