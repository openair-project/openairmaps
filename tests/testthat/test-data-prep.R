wind_df <- data.frame(
  ws = c(0, 2, 3, -1),
  wd = c(4, 123, 0, 400),
  nox = c(1, Inf, 3, -Inf),
  lab = c("Inf", "a", "b", "c")
)

test_that("checkMapPrep() treats data frames and tibbles identically", {
  df <- quietly(checkMapPrep(wind_df, names(wind_df)))
  tbl <- quietly(checkMapPrep(tibble::as_tibble(wind_df), names(wind_df)))
  expect_equal(as.data.frame(tbl), df)
})

test_that("checkMapPrep() cleans wind and pollutant data", {
  expect_warning(
    expect_warning(
      out <- checkMapPrep(wind_df, names(wind_df)),
      "Wind speed"
    ),
    "Wind direction"
  )
  # calms removed, wd rounded to 10 degrees with 0 as 360
  expect_equal(out$ws, c(NA, 2, 3, NA))
  expect_equal(out$wd, c(NA, 120, 360, NA))
  # infinite numbers become NA, but text is left alone
  expect_equal(out$nox, c(1, NA, 3, NA))
  expect_equal(out$lab, wind_df$lab)
})

test_that("checkMapPrep() can keep calms and negative wind speeds", {
  out <- quietly(
    checkMapPrep(wind_df, names(wind_df), remove.calm = FALSE, remove.neg = FALSE)
  )
  expect_equal(out$ws, wind_df$ws)
  expect_equal(out$wd, c(4, 123, 360, NA))
})

test_that("checkMapPrep() checks for missing variables", {
  expect_error(checkMapPrep(wind_df, c("ws", "foo")), "foo")
  # date-based types are allowed even if absent
  expect_no_error(quietly(checkMapPrep(wind_df, c("ws", "nox"))))
})

test_that("checkMapPrep() handles sites and dates", {
  df <- data.frame(
    date = as.POSIXct(c("2020-01-02", NA, "2020-01-01"), tz = "GMT"),
    site = c("a", "b", NA),
    x = 1:3
  )
  expect_warning(out <- checkMapPrep(df, c("x", "date", "site")), "1 lines")
  expect_equal(names(out)[1], "date")
  expect_equal(nrow(out), 1)

  # dates are sorted
  df$site <- "a"
  out <- quietly(checkMapPrep(df, c("date", "x", "site")))
  expect_equal(out$x, c(3, 1))

  df$date <- as.POSIXlt(df$date)
  expect_error(checkMapPrep(df, c("date", "x")), "POSIXct")

  df <- data.frame(date = factor("2020-01-01"), x = 1)
  expect_warning(checkMapPrep(df, c("date", "x")), "factor")

  df <- data.frame(
    date = as.POSIXct("2020-06-01", tz = "Europe/London"),
    x = 1
  )
  expect_message(checkMapPrep(df, c("date", "x")), "Daylight")
})

test_that("prepMapData() pivots pollutants into long format", {
  df <- data.frame(nox = 1:2, no2 = 3:4, lat = 1, lon = 2)
  out <- prepMapData(df, c("nox", "no2"), NULL, "lat", "lon")
  expect_equal(nrow(out), 4)
  expect_true(is.factor(out$pollutant_name))
  expect_equal(sort(unique(as.character(out$pollutant_name))), c("no2", "nox"))
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
  expect_equal(out$popup[[1]], "<b>Site Name</b>: a<br><b>NO<sub>x</sub></b>: 2")
  expect_equal(out$popup[[3]], "<b>Site Name</b>: b<br><b>NO<sub>x</sub></b>: 5")
})
