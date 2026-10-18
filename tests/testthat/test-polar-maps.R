# These use real openair plots, so are kept to a minimum - two sites, one month
# of data, and small figures. Branches of the internal helpers are tested more
# thoroughly (and quickly) in test-markers.R and test-legends.R.

skip_on_cran()

polar <- small_polar()
sites <- unique(polar$site)
one_site <- polar[polar$site == sites[[1]], ]
fig <- 1

test_that("polarMap() makes a dynamic map", {
  map <- quietly(polarMap(polar, "nox", d.fig = fig, progress = FALSE))
  expect_s3_class(map, "leaflet")
  expect_equal(nrow(get_marker_groups(map)), 2)
  # free limits - no shared legend
  expect_length(leaflet_legends(map), 0)
})

test_that("polar maps show the mean pollutant in popups and labels", {
  data <- small_polar()
  map <- quietly(polarMap(data, "nox", popup = "nox", label = "nox", d.fig = 1))
  call <- leaflet_calls(map, "addMarkers")[[1]]$args
  means <- tapply(data$nox, data$site, mean, na.rm = TRUE)

  expect_setequal(call[[11]], signif(unname(means), 3))
  expect_match(call[[7]], "^<b>NO<sub>x</sub> \\(mean\\)</b>: [0-9.]+$")

  # names are kept, and other pollutants are just like any other column
  map <- quietly(polarMap(
    data,
    c("nox", "no2"),
    popup = c("NOx conc." = "nox", "site"),
    d.fig = 1
  ))
  popups <- leaflet_calls(map, "addMarkers")[[1]]$args[[7]]
  expect_match(popups, "^<b>NO<sub>x</sub> conc.</b>: ")
})

test_that("polarMap() handles fixed limits, type and popups", {
  map <- quietly(polarMap(
    polar,
    "nox",
    limits = "fixed",
    upper = "free",
    type = "site",
    popup = c("site", "site_type"),
    label = "site",
    d.fig = fig,
    progress = FALSE
  ))
  groups <- get_marker_groups(map)
  expect_setequal(groups$group, sites)
  expect_equal(layer_control(map)$base, sort(sites))
  expect_equal(leaflet_legends(map)[[1]]$title, "NO<sub>x</sub>")
  popups <- leaflet_calls(map, "addMarkers")[[1]]$args[[7]]
  expect_true(all(grepl("Site Type", popups)))
})

test_that("polarMap() shares discrete breaks between markers", {
  map <- quietly(polarMap(
    polar,
    "nox",
    breaks = 4,
    upper = 10,
    legend.title = "my title",
    legend.title.autotext = FALSE,
    d.fig = fig,
    progress = FALSE
  ))
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "my title")
  expect_gt(length(legend$labels), 1)
})

test_that("polarMap() splits multiple pollutants", {
  expect_warning(
    map <- polarMap(
      polar[polar$site == sites[[1]], ],
      c("nox", "no2"),
      limits = "fixed",
      d.fig = fig,
      progress = FALSE
    ),
    "fixed"
  ) |>
    suppressMessages()
  expect_setequal(
    get_marker_groups(map)$group,
    c("NO<sub>x</sub>", "NO<sub>2</sub>")
  )
})

test_that("polarMap() skips sites that can't be plotted", {
  # too little data at the first site for a polar plot
  data <- dplyr::filter(
    polar,
    .data$site != sites[[1]] | seq_len(nrow(polar)) %% 200 == 0
  )
  map <- quietly(polarMap(
    data,
    "nox",
    type = "site",
    control.autotext = FALSE,
    d.fig = fig,
    progress = FALSE
  ))
  groups <- get_marker_groups(map)
  expect_equal(groups$group, sites[[2]])
  expect_equal(groups$lat, unique(polar$lat[polar$site == sites[[2]]]))
})

test_that("polarMap() makes static maps", {
  skip_if_not_installed("ggspatial")
  # pairwise statistics aren't faceted by pollutant
  map <- quietly(polarMap(
    polar,
    c("nox", "no2"),
    statistic = "r",
    limits = c(0, 1),
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "ggplot")
  expect_false(inherits(map$facet, "FacetWrap"))
  expect_equal(map$scales$get_scales("colour")$limits, c(0, 1))

  map <- quietly(polarMap(
    polar,
    "nox",
    type = "site",
    static = TRUE,
    static.nrow = 1,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map$facet, "FacetWrap")
})

test_that("polarMap() validates limits", {
  expect_error(
    quietly(polarMap(polar, "nox", limits = "foo", progress = FALSE)),
    "limits"
  )
})

test_that("annulusMap() makes maps", {
  skip_if_not_installed("ggspatial")
  # (polarAnnulus() is slow, so one site and one map)
  map <- quietly(annulusMap(
    one_site,
    "nox",
    limits = "fixed",
    type = "site",
    popup = c("site", "site_type"),
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "ggplot")
  expect_length(map$scales$get_scales("colour")$limits, 2)

  expect_error(quietly(annulusMap(polar, "nox", limits = "foo")), "limits")
})

test_that("freqMap() makes maps", {
  map <- quietly(freqMap(
    polar,
    statistic = "frequency",
    breaks = "fixed",
    popup = c("site", "site_type"),
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "frequency")

  skip_if_not_installed("ggspatial")
  map <- quietly(freqMap(
    polar,
    "nox",
    breaks = c(0, 50, 100, 1000),
    type = "site",
    static = TRUE,
    d.fig = c(1, 1.2),
    progress = FALSE
  ))
  expect_s3_class(map$facet, "FacetWrap")

  expect_error(quietly(freqMap(polar, "nox", breaks = "foo")), "breaks")
})

test_that("freqMap() allows trans with fixed breaks", {
  map <- quietly(freqMap(
    polar,
    "nox",
    breaks = "fixed",
    trans = "sqrt",
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
})

test_that("percentileMap() makes maps", {
  map <- quietly(percentileMap(
    one_site,
    "nox",
    percentile = c(50, 99),
    type = "site",
    popup = c("site", "site_type"),
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
  expect_equal(
    as.character(leaflet_legends(map)[[1]]$labels),
    c("0 - 50", "50 - 99")
  )

  skip_if_not_installed("ggspatial")
  map <- quietly(percentileMap(
    one_site,
    "nox",
    intervals = c(0, 100, 200, 500),
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "ggplot")

  expect_error(quietly(percentileMap(polar, intervals = "fixed")), "pollutant")
  expect_error(
    quietly(percentileMap(polar, "nox", intervals = "foo")),
    "intervals"
  )
})

test_that("percentileMap() uses percentile for fixed intervals", {
  percentile <- NULL
  real_fixed_scale_data <- fixed_scale_data
  local_mocked_bindings(fixed_scale_data = function(...) {
    percentile <<- list(...)$percentile
    real_fixed_scale_data(...)
  })

  quietly(percentileMap(
    one_site,
    "nox",
    percentile = c(50, 99),
    intervals = "fixed",
    d.fig = fig,
    progress = FALSE
  ))
  expect_equal(percentile, c(50, 99))
})

test_that("percentile_labels() matches openair's bands", {
  expect_equal(percentile_labels(c(50, 25)), c("0 - 25", "25 - 50"))
})

test_that("pollroseMap() makes maps", {
  map <- quietly(pollroseMap(
    polar,
    "nox",
    breaks = 4,
    type = "site",
    popup = c("site", "site_type"),
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
  expect_length(leaflet_legends(map), 1)

  skip_if_not_installed("ggspatial")
  map <- quietly(pollroseMap(
    polar,
    c("nox", "no2"),
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map$facet, "FacetWrap")
})

test_that("windroseMap() makes maps", {
  map <- quietly(windroseMap(
    polar,
    type = "site",
    popup = c("site", "site_type"),
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
  expect_equal(leaflet_legends(map)[[1]]$title, "Wind Speed")

  skip_if_not_installed("ggspatial")
  map <- quietly(windroseMap(
    polar,
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "ggplot")
})

test_that("diffMap() makes maps", {
  after <- dplyr::mutate(one_site, nox = .data$nox * 1.5)
  map <- quietly(diffMap(
    one_site,
    after,
    "nox",
    limits = c(-50, 50),
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "leaflet")
  expect_equal(nrow(get_marker_groups(map)), 1)
  expect_length(leaflet_legends(map), 1)

  skip_if_not_installed("ggspatial")
  map <- quietly(diffMap(
    one_site,
    after,
    "nox",
    type = "site",
    popup = c("site", "site_type"),
    static = TRUE,
    d.fig = fig,
    progress = FALSE
  ))
  expect_s3_class(map, "ggplot")

  expect_error(
    suppressMessages(diffMap(one_site, after, "nox", limits = "fixed")),
    "not supported"
  )
  expect_error(
    quietly(diffMap(one_site, after, "nox", limits = "foo")),
    "limits"
  )
})
