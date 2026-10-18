test_that("check_providers() validates dynamic providers", {
  expect_equal(check_providers(NULL, static = FALSE), "OpenStreetMap")
  expect_equal(
    check_providers("Esri.WorldGrayCanvas", static = FALSE),
    "Esri.WorldGrayCanvas"
  )
  # static shorthands are converted, and names are kept
  expect_equal(
    check_providers(c(HOTS = "hotstyle", "OpenStreetMap"), static = FALSE),
    c(HOTS = "OpenStreetMap.HOT", "OpenStreetMap")
  )
  expect_error(check_providers("OpenStreetMapp", static = FALSE))
})

test_that("check_providers() validates static providers", {
  expect_equal(unname(check_providers(NULL, static = TRUE)), "osm")
  expect_equal(
    unname(check_providers("OpenStreetMap.HOT", static = TRUE)),
    "hotstyle"
  )
  expect_equal(unname(check_providers("hotstyle", static = TRUE)), "hotstyle")
  expect_error(check_providers("not_a_provider", static = TRUE))
  expect_error(
    check_providers(c("osm", "cartodark"), static = TRUE),
    "single"
  )
})

test_that("check_legendposition() validates positions", {
  expect_equal(check_legendposition(NULL, static = FALSE), "topright")
  expect_equal(
    check_legendposition("bottomleft", static = FALSE),
    "bottomleft"
  )
  expect_error(check_legendposition("top", static = FALSE))
  expect_error(check_legendposition(c("topright", "bottomleft"), FALSE))

  expect_equal(check_legendposition("left", static = TRUE), "left")
  expect_error(check_legendposition("topright", static = TRUE))

  # static maps default to the ggplot2 theme's position
  old <- ggplot2::theme_set(
    ggplot2::theme_grey() + ggplot2::theme(legend.position = "bottom")
  )
  withr::defer(ggplot2::theme_set(old))
  expect_equal(check_legendposition(NULL, static = TRUE), "bottom")
})

test_that("check_multipoll() warns about fixed scales for many pollutants", {
  expect_equal(check_multipoll("fixed", "nox"), "fixed")
  expect_equal(check_multipoll("free", c("nox", "no2")), "free")
  expect_warning(
    out <- check_multipoll("fixed", c("nox", "no2")),
    "fixed"
  )
  expect_equal(out, "free")

  # the warning names the argument, and can be turned off
  expect_warning(
    check_multipoll("fixed", c("nox", "no2"), arg = "intervals"),
    "intervals = 'fixed'"
  )
  expect_no_warning(
    out <- check_multipoll("fixed", c("nox", "no2"), warn = FALSE)
  )
  expect_equal(out, "free")
})

test_that("ordinal() formats ordinal numbers", {
  expect_equal(ordinal(c(1, 2, 3, 4, 21, 101)), c("1st", "2nd", "3rd", "4th", "21st", "101st"))
  # the "teens" are exceptions
  expect_equal(ordinal(c(11, 12, 13, 112)), c("11th", "12th", "13th", "112th"))
  # decimals always use "th"
  expect_equal(ordinal(c(92.5, 99.9, 1.5)), c("92.5th", "99.9th", "1.5th"))
})

test_that("resolve_scale() handles fixed, free and numeric scales", {
  expect_equal(resolve_scale("fixed", "limits", fixed = 1:2), 1:2)
  expect_null(resolve_scale("free", "limits", fixed = 1:2))
  expect_equal(resolve_scale("free", "limits", fixed = 1:2, free = NA), NA)
  expect_equal(resolve_scale(c(0, 10), "limits", fixed = 1:2), c(0, 10))

  # "fixed" is only computed when it's needed
  expect_no_error(resolve_scale("free", "limits", fixed = stop("oops")))

  expect_error(resolve_scale("foo", "limits", fixed = 1:2), "limits")
  expect_error(
    resolve_scale("foo", "limits", fixed = 1:2, n = 2),
    "length 2"
  )
})

test_that("check_installed_static() passes when packages are installed", {
  skip_if_not_installed("ggspatial")
  skip_if_not_installed("prettymapr")
  skip_if_not_installed("ggtext")
  skip_if_not_installed("png")
  skip_if_not_installed("rosm")
  expect_no_error(check_installed_static())
})

test_that("assume_latlon() guesses latitude and longitude", {
  df <- data.frame(lat = 1, lon = 2)
  expect_message(
    expect_message(out <- assume_latlon(df, NULL, NULL), "latitude"),
    "longitude"
  )
  expect_equal(out, list(latitude = "lat", longitude = "lon"))

  df <- data.frame(Latitude = 1, LNG = 2)
  out <- assume_latlon(df, NULL, NULL, quiet = TRUE)
  expect_equal(out, list(latitude = "Latitude", longitude = "LNG"))

  # partially provided
  df <- data.frame(y = 1, long = 2)
  expect_message(
    expect_message(out <- assume_latlon(df, "y", NULL), "Latitude provided"),
    "Assuming longitude"
  )
  expect_equal(out, list(latitude = "y", longitude = "long"))
  expect_message(
    expect_message(
      out <- assume_latlon(data.frame(lat = 1, x = 2), NULL, "x"),
      "Assuming latitude"
    ),
    "Longitude provided"
  )
  expect_equal(out, list(latitude = "lat", longitude = "x"))

  # fully provided - no guessing
  expect_silent(out <- assume_latlon(df, "a", "b"))
  expect_equal(out, list(latitude = "a", longitude = "b"))

  expect_error(
    assume_latlon(data.frame(lat = 1, latitude = 2, lon = 3), NULL, NULL),
    "Multiple"
  )
  expect_error(
    assume_latlon(data.frame(x = 1, lon = 3), NULL, NULL),
    "No clear match"
  )
})
