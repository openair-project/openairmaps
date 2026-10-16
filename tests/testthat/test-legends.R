plots_with <- function(...) {
  data.frame(plot = I(list(...)))
}

test_that("create_legend_title() formats titles", {
  expect_equal(
    create_legend_title(FALSE, TRUE, NULL, "no2"),
    "NO<sub>2</sub>"
  )
  expect_equal(create_legend_title(FALSE, FALSE, NULL, "no2"), "no2")
  expect_equal(create_legend_title(FALSE, TRUE, "my title", "no2"), "my title")
  expect_type(create_legend_title(TRUE, TRUE, NULL, "no2"), "expression")
})

test_that("legend_from_markers() finds shared discrete scales", {
  lvls <- c("0 to 10", "10 to 20")
  plots_df <- plots_with(
    data.frame(z = factor(lvls[1], lvls)),
    NULL,
    data.frame(z = factor(lvls[2], lvls))
  )
  out <- legend_from_markers(plots_df, \(x) x$z, cols = "turbo")
  expect_equal(out$type, "discrete")
  expect_equal(out$labels, lvls)
  expect_length(out$colours, 2)

  # different intervals - no shared legend
  plots_df <- plots_with(
    data.frame(z = factor("a")),
    data.frame(z = factor("b"))
  )
  expect_null(legend_from_markers(plots_df, \(x) x$z, cols = "turbo"))
})

test_that("legend_from_markers() needs shared limits for continuous scales", {
  plots_df <- plots_with(data.frame(z = 1:2), data.frame(z = 3:4))

  expect_null(legend_from_markers(plots_df, \(x) x$z, cols = "turbo"))
  expect_null(legend_from_markers(plots_df, \(x) x$z, NA, cols = "turbo"))

  out <- legend_from_markers(plots_df, \(x) x$z, c(0, 10), cols = "turbo")
  expect_equal(out, legend_continuous(c(0, 10), "turbo"))

  # no legend for transformed scales
  expect_message(
    out <- legend_from_markers(
      plots_df,
      \(x) x$z,
      c(0, 10),
      cols = "turbo",
      trans = "log10"
    ),
    "trans"
  )
  expect_null(out)
})

test_that("legend_from_markers() returns NULL when nothing was plotted", {
  expect_null(
    legend_from_markers(plots_with(NULL, NULL), \(x) x$z, cols = "turbo")
  )
})

test_that("rose_intervals() reads intervals from an attribute", {
  data <- structure(data.frame(x = 1), intervals = c("0 to 2", "2 to 4"))
  expect_equal(
    rose_intervals(data),
    factor(c("0 to 2", "2 to 4"), c("0 to 2", "2 to 4"))
  )
})

test_that("add_polar_legend() adds leaflet legends", {
  map <- leaflet::leaflet()
  expect_identical(add_polar_legend(map, NULL, FALSE, "t", "topright"), map)

  out <- add_polar_legend(
    map,
    legend_continuous(c(0, 10), "turbo"),
    static = FALSE,
    title = "NOx",
    position = "bottomleft",
    alpha = 0.5
  )
  legend <- leaflet_legends(out)[[1]]
  expect_equal(legend$title, "NOx")
  expect_equal(legend$position, "bottomleft")
  expect_equal(legend$opacity, 0.5)

  out <- add_polar_legend(
    map,
    legend_discrete(c("a", "b", "c"), "turbo"),
    static = FALSE,
    title = "NOx",
    position = "topright"
  )
  legend <- leaflet_legends(out)[[1]]
  expect_equal(as.character(legend$labels), c("a", "b", "c"))
  # 6-digit hex codes only
  expect_true(all(nchar(legend$colors) == 7))
})

test_that("add_polar_legend() adds ggplot2 legends", {
  plots_df <- data.frame(lat = c(1, 2), lon = c(3, 4))
  map <- ggplot2::ggplot()

  out <- add_polar_legend(
    map,
    legend_continuous(c(0, 10), "turbo"),
    static = TRUE,
    title = "NOx",
    position = "right",
    plots_df = plots_df,
    latitude = "lat",
    longitude = "lon"
  )
  expect_s3_class(out, "ggplot")
  expect_equal(out$scales$get_scales("colour")$limits, c(0, 10))
  expect_equal(out$labels$colour, "NOx")

  out <- add_polar_legend(
    map,
    legend_discrete(c("a", "b"), "turbo"),
    static = TRUE,
    title = "NOx",
    position = "bottom",
    plots_df = plots_df,
    latitude = "lat",
    longitude = "lon"
  )
  expect_equal(nrow(out$layers[[1]]$data), 4)
  expect_equal(out$theme$legend.position, "bottom")
})
