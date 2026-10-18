skip_on_cran()

polar <- small_polar()
one_site <- polar[polar$site == unique(polar$site)[[1]], ]

test_that("addPolar*Markers() have all of the shared marker arguments", {
  for (fun in list(addPolarMarkers, addPolarDiffMarkers)) {
    expect_in(polar_marker_args, names(formals(fun)))
  }
})

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

test_that("addPolar*Markers() pass on `progress`", {
  progress <- NULL
  local_mocked_bindings(
    create_polar_markers = function(..., progress) {
      progress <<- progress
      stop("done")
    }
  )
  for (value in c(TRUE, FALSE)) {
    expect_error(
      addPolarMarkers(leaflet::leaflet(one_site), "nox", progress = value),
      "done"
    )
    expect_equal(progress, value)
    expect_error(
      addPolarDiffMarkers(leaflet::leaflet(one_site), "nox", progress = value),
      "done"
    )
    expect_equal(progress, value)
  }
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
