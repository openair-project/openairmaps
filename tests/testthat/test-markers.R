test_that("create_polar_markers() makes one marker per location and group", {
  out <- fake_markers()
  expect_equal(nrow(out), 3)
  expect_true(all(c("url", "plot", "data") %in% names(out)))

  # markers that couldn't be plotted are NULL, others are saved
  failed <- vapply(out$plot, is.null, logical(1))
  expect_equal(out$grp[failed], "Group B")
  expect_true(all(file.exists(out$url[!failed])))
  expect_false(any(file.exists(out$url[failed])))

  # default popups/labels
  expect_equal(unique(out$popup), "NA")
  expect_equal(unique(out$label), "NA")
})

test_that("create_polar_markers() drops missing data", {
  data <- fake_marker_data()
  data$conc[data$site == "A"] <- NA
  out <- fake_markers(data)
  expect_false("Group A" %in% out$grp)
})

test_that("create_polar_markers() errors with multiple popups per marker", {
  data <- fake_marker_data()
  expect_error(fake_markers(data, popup = "conc"), "Multiple popups")
})

test_that("create_polar_markers() pairs up before and after data", {
  data <- fake_marker_data()
  after <- dplyr::filter(data, .data$site != "C")
  expect_warning(
    out <- fake_markers(data, after = after),
    "Not matched"
  )
  expect_true("after" %in% names(out))
  expect_setequal(out$grp, c("Group A", "Group B"))
})

test_that("rm_illegal_chars() makes strings safe for file paths", {
  expect_equal(rm_illegal_chars("a b"), "aspaceb")
  expect_equal(rm_illegal_chars("<b>1/2</b>"), "leftchevronbrightchevron1forwardslash2leftchevronforwardslashbrightchevron")
  expect_equal(rm_illegal_chars("x:y?"), "xcolonyquestion")
})

test_that("attach_marker_icons() only adds markers that were plotted", {
  plots_df <- fake_markers()
  plots_df$grp_col <- plots_df$grp
  map <- attach_marker_icons(
    leaflet::leaflet(),
    data = plots_df,
    latitude = "lat",
    longitude = "lon",
    d.icon = c(50, 60),
    group_col = "grp_col",
    popup = "popup",
    label = "label",
    alpha = 0.5
  )
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  expect_equal(call[[1]], c(51, 53))
  expect_equal(call[[5]], c("Group A", "Group C"))
  expect_equal(call[[6]]$opacity, 0.5)
  expect_equal(call[[3]]$iconWidth, 50)
  expect_equal(call[[3]]$iconHeight, 60)
})

test_that("attach_marker_icons() passes single groups/layerIds to leaflet", {
  plots_df <- fake_markers()
  map <- attach_marker_icons(
    leaflet::leaflet(),
    data = plots_df,
    latitude = "lat",
    longitude = "lon",
    d.icon = 50,
    group = "my group",
    layerId = "id"
  )
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  expect_equal(call[[5]], "my group")
  expect_equal(call[[4]], "id")
})

test_that("attach_marker_icons() warns if no markers could be plotted", {
  plots_df <- fake_markers(dplyr::filter(fake_marker_data(), .data$site == "B"))
  expect_warning(
    map <- attach_marker_icons(
      leaflet::leaflet(),
      data = plots_df,
      latitude = "lat",
      longitude = "lon",
      d.icon = 50
    ),
    "No valid polar markers"
  )
  expect_length(leaflet_calls(map, "addMarkers"), 0)
})

test_that("make_leaflet_map() keeps groups aligned when plots fail", {
  map <- make_leaflet_map(
    fake_markers(),
    latitude = "lat",
    longitude = "lon",
    crs = 4326,
    provider = "OpenStreetMap",
    d.icon = 50,
    popup = NULL,
    label = NULL,
    split_col = "grp",
    control.collapsed = FALSE,
    control.position = "topright",
    control.autotext = FALSE,
    alpha = 1
  )
  groups <- get_marker_groups(map)
  expect_equal(groups$lat, c(51, 53))
  expect_equal(groups$group, c("Group A", "Group C"))
  # failed markers aren't in the layer control menu
  expect_equal(layer_control(map)$base, c("Group A", "Group C"))
})

test_that("make_leaflet_map() reprojects coordinates", {
  data <- fake_marker_data()
  pts <- sf::st_as_sf(data, coords = c("lon", "lat"), crs = 4326) |>
    sf::st_transform(27700) |>
    sf::st_coordinates()
  data$lon <- pts[, "X"]
  data$lat <- pts[, "Y"]

  map <- make_leaflet_map(
    fake_markers(data),
    latitude = "lat",
    longitude = "lon",
    crs = 27700,
    provider = c("OpenStreetMap", "CartoDB.Positron"),
    d.icon = 50,
    popup = NULL,
    label = NULL,
    split_col = "grp",
    control.collapsed = FALSE,
    control.position = "topright",
    control.autotext = TRUE,
    alpha = 1
  )
  expect_equal(get_marker_groups(map)$lat, c(51, 53), tolerance = 1e-6)
  expect_equal(
    leaflet_providers(map),
    c("OpenStreetMap", "CartoDB.Positron")
  )
})

test_that("create_static_map() skips markers that weren't plotted", {
  skip_if_not_installed("ggspatial")
  plots_df <- fake_markers()
  plots_df$grp <- factor(plots_df$grp)
  map <- create_static_map(
    plots_df,
    latitude = "lat",
    longitude = "lon",
    crs = 4326,
    provider = "osm",
    split_col = "grp",
    pollutant = "nox",
    d.icon = 50,
    facet = NULL,
    facet.nrow = NULL,
    api_key = NULL,
    alpha = 1
  )
  expect_s3_class(map, "ggplot")
  expect_equal(nrow(map$data), 2)
  expect_null(map$facet$params$facets)

  # with facets
  map <- create_static_map(
    plots_df,
    latitude = "lat",
    longitude = "lon",
    crs = 4326,
    provider = "osm",
    split_col = "grp",
    pollutant = "nox",
    d.icon = c(50, 60),
    facet = "grp",
    facet.nrow = 1,
    api_key = NULL,
    alpha = 1
  )
  expect_s3_class(map$facet, "FacetWrap")
  expect_equal(levels(map$data$grp), c("Group A", "Group B", "Group C"))
})

test_that("create_static_map() errors if no markers could be plotted", {
  skip_if_not_installed("ggspatial")
  plots_df <- fake_markers(dplyr::filter(fake_marker_data(), .data$site == "B"))
  expect_error(
    create_static_map(
      plots_df,
      latitude = "lat",
      longitude = "lon",
      crs = 4326,
      provider = "osm",
      split_col = "grp",
      pollutant = "nox",
      d.icon = 50,
      facet = NULL,
      facet.nrow = NULL,
      api_key = NULL,
      alpha = 1
    ),
    "No valid polar markers"
  )
})

test_that("create_static_map() applies alpha to markers", {
  skip_if_not_installed("ggspatial")
  skip_if_not_installed("png")
  plots_df <- fake_markers()
  ok <- !vapply(plots_df$plot, is.null, logical(1))

  # one RGB image, one RGBA image
  urls <- plots_df$url[ok]
  png::writePNG(array(0.5, c(4, 4, 3)), urls[[1]])
  png::writePNG(array(1, c(4, 4, 4)), urls[[2]])

  create_static_map(
    plots_df,
    latitude = "lat",
    longitude = "lon",
    crs = 4326,
    provider = "osm",
    split_col = "grp",
    pollutant = "nox",
    d.icon = 50,
    facet = NULL,
    facet.nrow = NULL,
    api_key = NULL,
    alpha = 0.4
  )
  for (url in urls) {
    img <- png::readPNG(url)
    expect_equal(dim(img)[3], 4)
    expect_equal(unique(as.vector(img[,, 4])), 0.4, tolerance = 1 / 255)
  }
})

test_that("resolve_shared_breaks() parses openair's intervals", {
  fake_fun <- function(mydata, type, breaks, ...) {
    expect_equal(type, ".marker")
    expect_null(breaks$labels)
    levels <- c("0 to 10", "10 to 20.5", "20.5 to 40")
    list(data = data.frame(z = factor(levels, levels)))
  }
  data <- data.frame(lat = 1, lon = 2, grp = "a")
  out <- resolve_shared_breaks(
    fake_fun,
    list(),
    data,
    breaks = 3,
    values = \(x) x$z,
    latitude = "lat",
    longitude = "lon",
    split_col = "grp"
  )
  expect_equal(out$breaks, c(-Inf, 10, 20.5, Inf))
  expect_equal(out$labels, c("0 to 10", "10 to 20.5", "20.5 to 40"))

  # user labels are kept
  out <- resolve_shared_breaks(
    fake_fun,
    list(),
    data,
    breaks = list(breaks = 3, labels = c("lo", "mid", "hi")),
    values = \(x) x$z,
    latitude = "lat",
    longitude = "lon",
    split_col = "grp"
  )
  expect_equal(out$labels, c("lo", "mid", "hi"))
})

test_that("resolve_shared_breaks() errors if intervals can't be parsed", {
  fake_fun <- function(mydata, ...) {
    list(data = data.frame(z = factor(c("low", "high"))))
  }
  expect_error(
    resolve_shared_breaks(
      fake_fun,
      list(),
      data.frame(lat = 1, lon = 2, grp = "a"),
      breaks = 3,
      values = \(x) x$z,
      latitude = "lat",
      longitude = "lon",
      split_col = "grp"
    ),
    "shared set of"
  )
})
