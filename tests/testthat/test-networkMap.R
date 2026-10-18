# networkMap() downloads metadata, so openair::importMeta() is replaced with a
# small, made-up version
fake_meta <- function(source, ..., all, duplicate) {
  dots <- list(...)
  meta <- dplyr::tibble(
    source = c("aurn", "aurn", "aurn", "saqn"),
    code = c("A1", "A1", "B1", "C1"),
    site = c("Site A", "Site A", "Site B", "Site C"),
    site_type = c("Urban", "Urban", NA, "Rural"),
    latitude = c(51, 51, 52, 56),
    longitude = c(-1, -1, -2, -4),
    variable = c("NO2", "BENZENE", "O3", "NO2"),
    Parameter_name = c(
      "Nitrogen dioxide",
      "Benzene",
      "Ozone",
      "Nitrogen dioxide"
    ),
    start_date = as.POSIXct(
      c("2000-01-01", "2001-01-01", "2002-01-01", "2003-01-01"),
      tz = "GMT"
    ),
    end_date = as.POSIXct(c(NA, "2010-01-01", NA, NA), tz = "GMT")
  )
  if (!is.null(dots$lat)) {
    meta$distance_km <- c(1, 1, 50, 500)
  }
  meta[meta$source %in% source, ]
}

local_fake_meta <- function(fun = fake_meta, env = parent.frame()) {
  local_mocked_bindings(importMeta = fun, .package = "openair", .env = env)
}

test_that("networkMap() makes a map of sites", {
  local_fake_meta()
  map <- networkMap(c("aurn", "saqn"))
  expect_s3_class(map, "leaflet")

  markers <- leaflet_calls(map, "addAwesomeMarkers")
  expect_length(markers, 1)
  # one marker per site
  expect_length(markers[[1]]$args[[1]], 3)

  # basemaps are base groups, markers can be toggled
  ctrl <- layer_control(map)
  expect_equal(ctrl$base, c("Default", "Satellite"))
  expect_equal(ctrl$overlay, "Markers")

  # multiple networks - legend
  expect_equal(leaflet_legends(map)[[1]]$title, "Network")
  expect_length(leaflet_legends(networkMap("aurn")), 0)
  expect_length(
    leaflet_legends(networkMap(c("aurn", "saqn"), legend = FALSE)),
    0
  )
})

test_that("networkMap() splits sites using control", {
  local_fake_meta()
  map <- networkMap(c("aurn", "saqn"), control = "site_type")
  # missing values become "Other", which goes last
  expect_equal(layer_control(map)$overlay, c("Rural", "Urban", "Other"))

  map <- networkMap(c("aurn", "saqn"), control = "source")
  expect_equal(layer_control(map)$overlay, c("aurn", "saqn"))

  expect_error(networkMap("aurn", control = "foo"), "control")
})

test_that("networkMap() splits sites by pollutant", {
  local_fake_meta()
  map <- networkMap(c("aurn", "saqn"), control = "variable")
  # pollutants are mutually exclusive, hydrocarbons are grouped together
  expect_equal(
    layer_control(map)$base,
    sort(c("HC", "NO<sub>2</sub>", "O<sub>3</sub>"))
  )
  # site popups show all of their variables
  popups <- unlist(lapply(
    leaflet_calls(map, "addAwesomeMarkers"),
    \(x) x$args[[7]]
  ))
  expect_true(any(grepl("Benzene", popups) & grepl("Nitrogen dioxide", popups)))
})

test_that("networkMap() shows a target location", {
  local_fake_meta()
  map <- networkMap("aurn", lat = 51, lng = -1, max_dist = 10, cluster = TRUE)
  markers <- leaflet_calls(map, "addAwesomeMarkers")
  expect_length(markers, 2)
  expect_match(markers[[1]]$args[[7]], "Search Location")
  expect_match(markers[[2]]$args[[7]][[1]], "Distance from Target")
  expect_length(leaflet_calls(map, "addPolylines"), 1)
  expect_equal(layer_control(map)$overlay, c("Markers", "Target"))
})

test_that("networkMap() returns a basemap when there are no sites", {
  local_fake_meta()
  map <- networkMap("local", provider = "OpenStreetMap")
  expect_length(leaflet_calls(map, "addAwesomeMarkers"), 0)
  expect_null(layer_control(map))
  expect_error(networkMap("aurn", provider = "foo"), "provider")
})

test_that("networkMap() popups show when each site was active", {
  local_fake_meta(function(source, ...) {
    dplyr::tibble(
      source = "aurn",
      code = "A1",
      site = "Site A",
      latitude = 51,
      longitude = -1,
      variable = c("NO2", "O3", "SO2"),
      Parameter_name = c("Nitrogen dioxide", "Ozone", "Sulphur dioxide"),
      start_date = as.POSIXct(c(NA, "2001-01-01", "2005-01-01"), tz = "GMT"),
      end_date = as.POSIXct(c("2010-01-01", NA, "2008-01-01"), tz = "GMT")
    )
  })
  popup <- leaflet_calls(networkMap(), "addAwesomeMarkers")[[1]]$args[[7]]

  # missing start dates are ignored, but a missing end date means the site is
  # still active
  expect_match(popup, "Active from</span><span[^>]*>2001-01-01")
  expect_match(popup, "Active to</span><span[^>]*>Ongoing")
})

test_that("networkMap() handles imperial metadata", {
  local_fake_meta(function(source, ...) {
    dplyr::tibble(
      source = "imperial",
      code = "I1",
      site = "Site I",
      site_type = "Urban",
      latitude = 51,
      longitude = 0,
      OpeningDate = as.POSIXct("2000-01-01", tz = "GMT"),
      ClosingDate = as.POSIXct("2005-01-01", tz = "GMT")
    )
  })
  map <- networkMap("imperial")
  popup <- leaflet_calls(map, "addAwesomeMarkers")[[1]]$args[[7]]
  expect_match(popup, "2000-01-01")
  expect_match(popup, "2005-01-01")
})
