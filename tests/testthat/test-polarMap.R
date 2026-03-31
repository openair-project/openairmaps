if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
  return()
}

test_data <- dplyr::bind_rows(unname(lapply(split(polar_data, ~site), \(x) {
  head(x, n = 500)
})))

if (!mirai::daemons_set()) {
  mirai::daemons(n = 4)
  withr::defer(mirai::daemons(0), teardown_env())
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

is_leaflet <- function(x) inherits(x, "leaflet")
is_ggplot <- function(x) inherits(x, "gg")

# ---------------------------------------------------------------------------
# polarMap
# ---------------------------------------------------------------------------

test_that("polarMap returns a leaflet for dynamic maps", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap returns a ggplot for static maps", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("polarMap works with limits = 'fixed'", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = "fixed",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap works with numeric limits", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = c(0, 100),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap errors on unrecognised limits string", {
  expect_error(
    polarMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      limits = "invalid",
      progress = FALSE
    ),
    regexp = "limits"
  )
})

test_that("polarMap works with multiple pollutants", {
  out <- polarMap(
    test_data,
    pollutant = c("nox", "no2"),
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap works with type argument (dynamic)", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap works with type argument (static)", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("polarMap respects upper = 'free'", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    upper = "free",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap respects numeric upper", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    upper = 10,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap respects legend = FALSE (dynamic)", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = "fixed",
    legend = FALSE,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap respects legend = FALSE (static)", {
  out <- polarMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = "fixed",
    legend = FALSE,
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("polarMap errors when pollutant is NULL", {
  expect_error(
    polarMap(
      test_data,
      pollutant = NULL,
      latitude = "lat",
      longitude = "lon",
      progress = FALSE
    ),
    regexp = "pollutant"
  )
})

# ---------------------------------------------------------------------------
# annulusMap
# ---------------------------------------------------------------------------

test_that("annulusMap returns a leaflet for dynamic maps", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("annulusMap returns a ggplot for static maps", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("annulusMap works with each period option", {
  for (p in c("hour", "season", "weekday", "trend")) {
    annulus_data <- test_data
    if (p == "season") {
      annulus_data <- polar_data
    }
    out <- annulusMap(
      annulus_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      period = p,
      progress = FALSE
    )
    expect_true(is_leaflet(out), label = paste("period =", p))
  }
})

test_that("annulusMap works with limits = 'fixed'", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = "fixed",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("annulusMap works with numeric limits", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    limits = c(0, 200),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("annulusMap errors on unrecognised limits string", {
  expect_error(
    annulusMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      limits = "bad",
      progress = FALSE
    ),
    regexp = "limits"
  )
})

test_that("annulusMap works with type (dynamic)", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("annulusMap works with type (static)", {
  out <- annulusMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("annulusMap errors when pollutant is NULL", {
  expect_error(
    annulusMap(
      test_data,
      pollutant = NULL,
      latitude = "lat",
      longitude = "lon",
      progress = FALSE
    ),
    regexp = "pollutant"
  )
})

# ---------------------------------------------------------------------------
# freqMap
# ---------------------------------------------------------------------------

test_that("freqMap returns a leaflet for dynamic maps", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("freqMap returns a ggplot for static maps", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("freqMap works with statistic = 'frequency' (no pollutant needed)", {
  out <- freqMap(
    test_data,
    pollutant = NULL,
    statistic = "frequency",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("freqMap works with each statistic option", {
  stats <- c("mean", "median", "max", "stdev", "weighted.mean")
  for (s in stats) {
    out <- freqMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      statistic = s,
      progress = FALSE
    )
    expect_true(is_leaflet(out), label = paste("statistic =", s))
  }
})

test_that("freqMap works with breaks = 'fixed'", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = "fixed",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("freqMap works with numeric breaks vector", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = seq(0, 200, 20),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("freqMap errors on unrecognised breaks string", {
  expect_error(
    freqMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      breaks = "bad",
      progress = FALSE
    ),
    regexp = "breaks"
  )
})

test_that("freqMap works with type (dynamic)", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("freqMap works with type (static)", {
  out <- freqMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("freqMap errors when pollutant is NULL and statistic != 'frequency'", {
  expect_error(
    freqMap(test_data, pollutant = NULL, statistic = "mean", progress = FALSE),
    regexp = "pollutant"
  )
})

# ---------------------------------------------------------------------------
# percentileMap
# ---------------------------------------------------------------------------

test_that("percentileMap returns a leaflet for dynamic maps", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap returns a ggplot for static maps", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("percentileMap works with custom percentile vector", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    percentile = c(50, 75, 95),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap works with percentile = NA (mean line only)", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    percentile = NA,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap works with intervals = 'free'", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    intervals = "free",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap works with numeric intervals", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    intervals = c(0, 20, 50, 100),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap errors on unrecognised intervals string", {
  expect_error(
    percentileMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      intervals = "bad",
      progress = FALSE
    ),
    regexp = "intervals"
  )
})

test_that("percentileMap works with type (dynamic)", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("percentileMap works with type (static)", {
  out <- percentileMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("percentileMap errors when pollutant is NULL", {
  expect_error(
    percentileMap(
      test_data,
      pollutant = NULL,
      latitude = "lat",
      longitude = "lon",
      progress = FALSE
    ),
    regexp = "pollutant"
  )
})

# ---------------------------------------------------------------------------
# pollroseMap
# ---------------------------------------------------------------------------

test_that("pollroseMap returns a leaflet for dynamic maps", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("pollroseMap returns a ggplot for static maps", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("pollroseMap works with each statistic option", {
  for (s in c("prop.count", "prop.mean", "abs.count")) {
    out <- pollroseMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      statistic = s,
      progress = FALSE
    )
    expect_true(is_leaflet(out), label = paste("statistic =", s))
  }
})

test_that("pollroseMap works with scalar breaks", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = 5,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("pollroseMap works with specific numeric breaks", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = c(0, 1, 10, 100),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("pollroseMap adds legend when breaks specified (dynamic)", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = 4,
    legend = TRUE,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
  # legend control should be present in the map calls list
  calls <- out$x$calls
  legend_calls <- Filter(function(c) c$method == "addLegend", calls)
  expect_gt(length(legend_calls), 0)
})

test_that("pollroseMap does not add legend when legend = FALSE", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    breaks = 4,
    legend = FALSE,
    progress = FALSE
  )
  calls <- out$x$calls
  legend_calls <- Filter(function(c) c$method == "addLegend", calls)
  expect_equal(length(legend_calls), 0)
})

test_that("pollroseMap works with type (dynamic)", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("pollroseMap works with type (static)", {
  out <- pollroseMap(
    test_data,
    pollutant = "nox",
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("pollroseMap errors when pollutant is NULL", {
  expect_error(
    pollroseMap(
      test_data,
      pollutant = NULL,
      latitude = "lat",
      longitude = "lon",
      progress = FALSE
    ),
    regexp = "pollutant"
  )
})

# ---------------------------------------------------------------------------
# windroseMap
# ---------------------------------------------------------------------------

test_that("windroseMap returns a leaflet for dynamic maps", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("windroseMap returns a ggplot for static maps", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

test_that("windroseMap works with scalar breaks", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    breaks = 5,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("windroseMap works with specific numeric breaks", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    breaks = c(0, 2, 4, 6, 8),
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("windroseMap works with custom ws.int", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    ws.int = 1,
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("windroseMap adds a legend by default (dynamic)", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    progress = FALSE
  )
  calls <- out$x$calls
  legend_calls <- Filter(function(c) c$method == "addLegend", calls)
  expect_gt(length(legend_calls), 0)
})

test_that("windroseMap does not add legend when legend = FALSE", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    legend = FALSE,
    progress = FALSE
  )
  calls <- out$x$calls
  legend_calls <- Filter(function(c) c$method == "addLegend", calls)
  expect_equal(length(legend_calls), 0)
})

test_that("windroseMap works with type (dynamic)", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    type = "season",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("windroseMap works with type (static)", {
  out <- windroseMap(
    test_data,
    latitude = "lat",
    longitude = "lon",
    type = "season",
    static = TRUE,
    progress = FALSE
  )
  expect_true(is_ggplot(out))
})

# ---------------------------------------------------------------------------
# Shared argument behaviour across all map functions
# ---------------------------------------------------------------------------

map_fns <- list(
  polarMap = function(...) {
    polarMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      ...
    )
  },
  annulusMap = function(...) {
    annulusMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      ...
    )
  },
  freqMap = function(...) {
    freqMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      ...
    )
  },
  percentileMap = function(...) {
    percentileMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      ...
    )
  },
  pollroseMap = function(...) {
    pollroseMap(
      test_data,
      pollutant = "nox",
      latitude = "lat",
      longitude = "lon",
      ...
    )
  },
  windroseMap = function(...) {
    windroseMap(test_data, latitude = "lat", longitude = "lon", ...)
  }
)

test_that("all map functions accept alpha argument", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](alpha = 0.5, progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept cols argument", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](cols = "viridis", progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept d.icon / d.fig arguments", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](d.icon = 150, d.fig = 3, progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept non-square d.icon vector", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](d.icon = c(200, 150), progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept legend.title override", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](legend.title = "My Legend", progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept control.collapsed = TRUE", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](
      type = "season",
      control.collapsed = TRUE,
      progress = FALSE
    )
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept control.position options", {
  positions <- c("topleft", "topright", "bottomleft", "bottomright")
  for (p in positions) {
    out <- map_fns[["polarMap"]](
      type = "season",
      control.position = p,
      progress = FALSE
    )
    expect_true(is_leaflet(out), label = paste("control.position =", p))
  }
})

test_that("all map functions accept multiple providers (dynamic)", {
  providers <- c("OpenStreetMap", "CartoDB.Positron")
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](provider = providers, progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept named provider vector (dynamic)", {
  providers <- c("Default" = "OpenStreetMap", "Minimal" = "CartoDB.Positron")
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](provider = providers, progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all static map functions accept static.nrow", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](
      type = "season",
      static = TRUE,
      static.nrow = 2,
      progress = FALSE
    )
    expect_true(is_ggplot(out), label = nm)
  }
})

test_that("all map functions accept label argument without error", {
  for (nm in names(map_fns)) {
    # test_data is assumed to have a 'site' column based on typical openair data
    out <- map_fns[[nm]](label = "site", progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

test_that("all map functions accept popup argument without error", {
  for (nm in names(map_fns)) {
    out <- map_fns[[nm]](popup = "site", progress = FALSE)
    expect_true(is_leaflet(out), label = nm)
  }
})

# ---------------------------------------------------------------------------
# Coordinate / CRS handling
# ---------------------------------------------------------------------------

test_that("polarMap accepts explicit latitude/longitude column names", {
  # test_data uses 'lat' and 'lon' by default; rename to test explicit passing
  data_renamed <- test_data
  names(data_renamed)[names(data_renamed) == "lat"] <- "my_lat"
  names(data_renamed)[names(data_renamed) == "lon"] <- "my_lon"

  out <- polarMap(
    data_renamed,
    pollutant = "nox",
    latitude = "my_lat",
    longitude = "my_lon",
    progress = FALSE
  )
  expect_true(is_leaflet(out))
})

test_that("polarMap infers lat/lon when not provided", {
  # Should not error; just check the info message is generated
  expect_message(
    polarMap(
      test_data,
      pollutant = "nox",
      progress = FALSE
    ),
    class = "cliMessage"
  )
})
