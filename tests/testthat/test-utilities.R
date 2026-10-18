test_that("quickTextHTML() formats pollutants and units", {
  expect_equal(
    quickTextHTML(c("no2", "NOx", "pm2.5", "o3", "co2")),
    c(
      "NO<sub>2</sub>",
      "NO<sub>x</sub>",
      "PM<sub>2.5</sub>",
      "O<sub>3</sub>",
      "CO<sub>2</sub>"
    )
  )
  expect_equal(quickTextHTML("ws"), "wind spd.")
  expect_equal(
    quickTextHTML("no2 (ug/m3)"),
    "NO<sub>2</sub> (µg&nbsp;m<sup>-3</sup>)"
  )
  expect_equal(quickTextHTML("m/s"), "m&nbsp;s<sup>-1</sup>")
  expect_equal(quickTextHTML("m/s2"), "m&nbsp;s<sup>-2</sup>")
  # only whole words are replaced
  expect_equal(quickTextHTML("snow"), "snow")
})

popup_data <- data.frame(
  lat = c(1, 1, 2),
  lon = c(1, 1, 2),
  site = c("A", "A", "B"),
  type = c("x", "y", "x"),
  nox = c(1, 3, 5),
  date = as.POSIXct(c("2020-01-01", "2020-02-01", "2020-03-01"), tz = "GMT"),
  day = as.Date(c("2020-01-01", "2020-02-01", "2020-03-01")),
  flag = c(TRUE, FALSE, TRUE)
)

test_that("buildPopup() summarises columns by location", {
  out <- quietly(buildPopup(popup_data, c("Site" = "site", "nox", "date")))
  expect_equal(nrow(out), 3)
  expect_equal(
    popup_text(out$popup[[1]]),
    "Site: A; NO<sub>x</sub>: 2; date: 2020-01-01 to 2020-02-01"
  )
  expect_equal(out$popup[[1]], out$popup[[2]])

  # unnamed columns
  out <- quietly(buildPopup(popup_data, "site"))
  expect_equal(popup_text(out$popup[[3]]), "site: B")
})

test_that("buildPopup() supports all column types and custom summaries", {
  out <- quietly(buildPopup(
    popup_data,
    c("day", "flag", "nox"),
    fun.character = \(x) length(unique(x)),
    fun.numeric = \(x) max(x),
    fun.dttm = \(x) format(min(x), "%Y")
  ))
  expect_equal(
    popup_text(out$popup[[1]]),
    "day: 2020; flag: 2; NO<sub>x</sub>: 3"
  )
})

test_that("buildPopup() summarises separately by type", {
  out <- quietly(buildPopup(popup_data, "nox", type = "type"))
  expect_equal(nrow(out), 3)
  expect_equal(popup_text(out$popup[out$type == "y"]), "NO<sub>x</sub>: 3")
  expect_equal(
    popup_text(out$popup[out$type == "x" & out$site == "A"]),
    "NO<sub>x</sub>: 1"
  )

  # styled like the package's other popups
  expect_match(out$popup, "^<div style='font-family:sans-serif;")
  expect_match(out$popup, "<span style='color:#888; min-width:100px;'>")
})

test_that("convertPostcode() returns a latitude and longitude", {
  skip_if_not_installed("curl")
  skip_if_not_installed("jsonlite")
  local_mocked_bindings(
    curl_fetch_memory = function(url, ...) {
      expect_equal(url, "api.postcodes.io/postcodes/sw1a1aa")
      list(
        status_code = 200L,
        content = charToRaw(
          '{"result": {"latitude": 51.5, "longitude": -0.14, "postcode": "SW1A 1AA"}}'
        )
      )
    },
    .package = "curl"
  )
  expect_equal(
    convertPostcode("SW1A 1AA"),
    list(lat = 51.5, lng = -0.14, postcode = "SW1A 1AA")
  )
})

test_that("convertPostcode() errors for invalid postcodes", {
  skip_if_not_installed("curl")
  skip_if_not_installed("jsonlite")
  local_mocked_bindings(
    curl_fetch_memory = function(url, ...) {
      list(
        status_code = 404L,
        content = charToRaw('{"error": "Invalid postcode"}')
      )
    },
    .package = "curl"
  )
  expect_error(convertPostcode("foo"), "Invalid postcode")
})
