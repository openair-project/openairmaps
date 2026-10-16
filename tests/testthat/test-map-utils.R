test_that("name_providers() names and de-duplicates providers", {
  expect_equal(
    name_providers(c("OpenStreetMap", "CartoDB.Positron")),
    c(OpenStreetMap = "OpenStreetMap", CartoDB.Positron = "CartoDB.Positron")
  )
  expect_equal(
    name_providers(c(Default = "OpenStreetMap", "Esri", "OpenStreetMap")),
    c(Default = "OpenStreetMap", Esri = "Esri")
  )
})

test_that("add_basemaps() adds each provider as its own group", {
  map <- add_basemaps(
    leaflet::leaflet(),
    c(Default = "OpenStreetMap", "CartoDB.Positron")
  )
  calls <- leaflet_calls(map, "addProviderTiles")
  expect_equal(leaflet_providers(map), c("OpenStreetMap", "CartoDB.Positron"))
  expect_equal(
    vapply(calls, \(x) x$args[[3]], ""),
    c("Default", "CartoDB.Positron")
  )
})

test_that("add_layer_control() handles groups and providers", {
  map <- leaflet::leaflet()
  one <- "OpenStreetMap"
  two <- c(A = "OpenStreetMap", B = "CartoDB.Positron")

  # nothing to switch between
  expect_null(layer_control(add_layer_control(map, one)))
  expect_null(layer_control(add_layer_control(map, one, groups = "x")))

  # base groups
  out <- layer_control(add_layer_control(map, one, groups = c("x", "y")))
  expect_equal(out$base, c("x", "y"))
  expect_length(out$overlay, 0)

  # base groups with multiple providers - providers become overlays
  ctrl <- add_layer_control(map, two, groups = c("x", "y"))
  out <- layer_control(ctrl)
  expect_equal(out$base, c("x", "y"))
  expect_equal(out$overlay, c("A", "B"))
  expect_equal(leaflet_calls(ctrl, "hideGroup")[[1]]$args[[1]], "B")

  # overlay groups - providers stay as base groups
  out <- layer_control(
    add_layer_control(map, two, groups = c("x", "y"), groups_as = "overlay")
  )
  expect_equal(out$base, c("A", "B"))
  expect_equal(out$overlay, c("x", "y"))

  # just providers
  out <- layer_control(add_layer_control(map, two))
  expect_equal(out$base, c("A", "B"))
})

test_that("estimate_bbox() pads the bounding box", {
  pts <- sf::st_as_sf(
    data.frame(x = c(0, 2), y = c(0, 2)),
    coords = c("x", "y"),
    crs = 4326
  )
  bbox <- estimate_bbox(pts)
  expect_equal(unname(unlist(bbox)), c(-1, -1, 3, 3))
})

test_that("theme_static() is a complete ggplot2 theme", {
  expect_s3_class(theme_static(), "theme")
  expect_s3_class(theme_static()$panel.border, "element_rect")
})

test_that("geom_sf_richtext() creates a layer", {
  skip_if_not_installed("ggtext")
  expect_s3_class(geom_sf_richtext(), "LayerInstance")
  expect_s3_class(geom_sf_richtext(nudge_x = 1), "LayerInstance")
  expect_error(
    geom_sf_richtext(nudge_x = 1, position = "identity"),
    "position"
  )
})
