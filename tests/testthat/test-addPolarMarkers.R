skip_on_cran()

polar <- small_polar()
one_site <- polar[polar$site == unique(polar$site)[[1]], ]

test_that("addPolarMarkers() adds markers to a leaflet map", {
  map <- leaflet::leaflet(polar) |>
    addPolarMarkers(
      "ws",
      fun = openair::windRose,
      group = "Wind Rose",
      layerId = c("a", "b"),
      popup = "site",
      label = "site_type",
      d.fig = 1,
      alpha = 0.5
    ) |>
    quietly()
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  expect_length(call[[1]], 2)
  expect_equal(call[[5]], "Wind Rose")
  expect_equal(call[[4]], c("a", "b"))
  expect_equal(call[[6]]$opacity, 0.5)
  expect_setequal(call[[7]], unique(polar$site))
})

test_that("addPolarMarkers() can override the map's data", {
  map <- leaflet::leaflet() |>
    addPolarMarkers(
      "ws",
      fun = openair::windRose,
      data = one_site,
      lat = "lat",
      lng = "lon",
      d.fig = 1
    ) |>
    quietly()
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  expect_equal(call[[1]], unique(one_site$lat))
  expect_null(call[[5]])
})

test_that("addPolarDiffMarkers() adds markers to a leaflet map", {
  after <- dplyr::mutate(one_site, nox = .data$nox * 2)
  map <- leaflet::leaflet(one_site) |>
    addPolarDiffMarkers("nox", after = after, group = "diff", d.fig = 1) |>
    quietly()
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  expect_length(call[[1]], 1)
  expect_equal(call[[5]], "diff")
})
