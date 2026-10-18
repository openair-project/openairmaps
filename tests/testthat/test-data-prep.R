wind_df <- data.frame(
  ws = c(0, 2, 3, -1),
  wd = c(4, 123, 0, 400),
  nox = c(1, Inf, 3, -Inf),
  lab = c("Inf", "a", "b", "c")
)

test_that("prepMapData() leaves wind data for openair to check", {
  out <- expect_no_warning(
    prepMapData(wind_df, "nox", NULL, "ws", "wd", "lab", .to_narrow = FALSE)
  )
  # calms are kept, and wind directions aren't rounded
  expect_equal(out$ws, wind_df$ws)
  expect_equal(out$wd, wind_df$wd)
  # infinite pollutant values become NA, but text is left alone
  expect_equal(out$nox, c(1, NA, 3, NA))
  expect_equal(out$lab, wind_df$lab)

  # data frames and tibbles are treated identically
  tbl <- prepMapData(
    dplyr::as_tibble(wind_df),
    "nox",
    NULL,
    "ws",
    .to_narrow = FALSE
  )
  expect_equal(as.data.frame(tbl), as.data.frame(out[c("nox", "ws")]))
})

test_that("prepMapData() pivots pollutants into long format", {
  df <- data.frame(nox = 1:2, no2 = 3:4, lat = 1, lon = 2)
  out <- prepMapData(df, c("nox", "no2"), NULL, "lat", "lon")
  expect_equal(nrow(out), 4)
  expect_true(is.factor(out$pollutant_name))
  # pollutants keep the order they were given in
  expect_equal(levels(out$pollutant_name), c("nox", "no2"))
  expect_equal(out$conc, c(1, 3, 2, 4))

  out <- prepMapData(df, "nox", NULL, "lat", .to_narrow = FALSE)
  expect_named(out, c("nox", "lat"))
})

test_that("prepMapData() checks its inputs", {
  df <- data.frame(nox = 1, no2 = 2, site = "a")
  expect_error(prepMapData(df, NULL, NULL), "pollutant")
  expect_error(prepMapData(df, "foo", NULL), "foo")
  expect_warning(
    prepMapData(df, c("nox", "no2"), "site"),
    "Multiple pollutants"
  )
  expect_no_warning(
    prepMapData(df, c("nox", "no2"), "site", .pairwise = TRUE)
  )
})

test_that("getBreaks() works out rose breaks", {
  vec <- 0:20
  # wind roses use ws.int
  expect_equal(getBreaks(4, 2, vec, polrose = FALSE), c(0, 2, 4, 6, 20))
  # pollution roses use pretty breaks
  out <- getBreaks(6, NULL, vec, polrose = TRUE)
  expect_equal(min(out), 0)
  expect_equal(max(out), 20)
  expect_false(is.unsorted(out))
  # vectors are kept, but extended to the maximum
  expect_equal(getBreaks(c(10, 0), 2, vec, polrose = TRUE), c(0, 10, 20))
  expect_equal(getBreaks(c(0, 30), 2, vec, polrose = FALSE), c(0, 30))
})

test_that("quick_popup() combines columns into a popup", {
  df <- data.frame(
    lat = c(1, 1, 2),
    lon = c(1, 1, 2),
    site_name = c("a", "a", "b"),
    nox = c(1, 3, 5),
    # (always added by openair::cutData() before quick_popup() is used)
    default = "all data"
  )
  out <- quick_popup(df, c("site_name", "nox"), "lat", "lon", NULL)
  expect_true("popup" %in% names(out))
  expect_equal(
    popup_text(out$popup[[1]]),
    "Site Name: a; NO<sub>x</sub>: 2"
  )
  expect_equal(
    popup_text(out$popup[[3]]),
    "Site Name: b; NO<sub>x</sub>: 5"
  )
})
