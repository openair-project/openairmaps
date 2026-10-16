traj <- small_traj()
n_traj <- length(unique(traj$date))

# a second receptor, arriving at the same times but elsewhere
two_receptors <- dplyr::bind_rows(
  traj,
  dplyr::mutate(traj, receptor = 2L, lon = .data$lon + 5)
)

# the largest jump in longitude within any single trajectory line
max_lon_jump <- function(map) {
  lines <- leaflet_calls(map, "addPolylines")
  max(vapply(lines, \(x) max(abs(diff(x$args[[1]][[1]][[1]][[1]]$lng))), 1))
}

# Helpers ----------------------------------------------------------------------

test_that("traj_id() identifies trajectories by date and receptor", {
  expect_equal(nlevels(traj_id(traj)), n_traj)
  expect_equal(nlevels(traj_id(two_receptors)), n_traj * 2)
  expect_equal(
    nlevels(traj_id(dplyr::select(two_receptors, -"receptor"))),
    n_traj
  )
})

test_that("build_traj_labels() makes popups", {
  out <- build_traj_labels(traj[1:2, ])
  expect_true(all(grepl("ARRIVAL DATE", out$lab)))
  expect_false(any(grepl("nox", out$lab)))

  out <- build_traj_labels(traj[1:2, ], extra = "nox")
  expect_true(all(grepl("NO<sub>x</sub>", out$lab)))
})

test_that("build_traj_level_labels() makes popups", {
  data <- data.frame(
    label = c(1, 2),
    gridcount = c(NA, 5),
    xgrid = 1,
    ygrid = 2,
    season = "winter"
  )
  out <- build_traj_level_labels(data, "MEAN")
  expect_false(grepl("Count", out[[1]]))
  expect_true(grepl("Count", out[[2]]))
  expect_false(any(grepl("winter", out)))

  out <- build_traj_level_labels(data, "MEAN", type = "season")
  expect_true(all(grepl("winter", out)))
})

test_that("popup helpers build HTML", {
  expect_match(popup_row("a", 1), "<span[^>]*>a</span>")
  expect_match(popup_section("x"), "border-top")
  expect_match(popup_card("t", "s", "body"), "t.*s.*body")
})

# trajMap() --------------------------------------------------------------------

test_that("trajMap() draws one line per trajectory", {
  map <- trajMap(traj)
  expect_s3_class(map, "leaflet")
  expect_length(leaflet_calls(map, "addPolylines"), n_traj)
  expect_equal(
    unique(vapply(leaflet_calls(map, "addPolylines"), \(x) x$args[[4]]$color, "")),
    "black"
  )
  expect_length(leaflet_legends(map), 0)
})

test_that("trajMap() supports multiple receptors", {
  map <- trajMap(two_receptors)
  expect_length(leaflet_calls(map, "addPolylines"), n_traj * 2)
  expect_lt(max_lon_jump(map), 5)
})

test_that("trajMap() colours trajectories", {
  # fixed colour
  map <- trajMap(traj, colour = "red")
  colours <- vapply(leaflet_calls(map, "addPolylines"), \(x) x$args[[4]]$color, "")
  expect_equal(unique(colours), "red")

  # numeric
  map <- trajMap(traj, colour = "nox", legend.title = "my nox")
  expect_equal(leaflet_legends(map)[[1]]$title, "my NO<sub>x</sub>")
  expect_gt(length(unique(
    vapply(leaflet_calls(map, "addPolylines"), \(x) x$args[[4]]$color, "")
  )), 1)

  # factor
  traj$fct <- factor(rep(c("a", "b"), length.out = nrow(traj)))
  map <- trajMap(traj, colour = "fct", legend.title.autotext = FALSE)
  expect_equal(leaflet_legends(map)[[1]]$title, "fct")

  # dates
  map <- trajMap(traj, colour = "date")
  expect_length(leaflet_legends(map), 1)
})

test_that("trajMap() splits trajectories by type", {
  map <- trajMap(traj, type = "hour")
  hours <- unique(format(traj$date, "%H"))
  expect_setequal(layer_control(map)$overlay, as.character(as.numeric(hours)))
})

test_that("trajMap() supports deprecated control and other providers", {
  withr::local_options(lifecycle_verbosity = "quiet")
  map <- trajMap(traj, control = "hour", provider = c("OpenStreetMap", "cartolight"))
  expect_equal(leaflet_providers(map), c("OpenStreetMap", "CartoDB.Positron"))
  expect_length(layer_control(map)$overlay, length(unique(traj$date)))
  expect_error(trajMap(traj, provider = "foo"), "provider")
})

# addTrajPaths() ---------------------------------------------------------------

test_that("addTrajPaths() adds lines and points", {
  map <- leaflet::leaflet() |>
    addTrajPaths(data = traj, group = "trajs", color = "blue")
  expect_length(leaflet_calls(map, "addPolylines"), n_traj)
  points <- leaflet_calls(map, "addCircleMarkers")
  expect_length(points, n_traj)
  # points every 12 hours
  expect_true(all(traj$hour.inc[traj$hour.inc %% 12 == 0] %% 12 == 0))
  expect_equal(points[[1]]$args[[5]], "trajs")
})

test_that("addTrajPaths() supports multiple receptors", {
  map <- leaflet::leaflet() |> addTrajPaths(data = two_receptors)
  expect_length(leaflet_calls(map, "addPolylines"), n_traj * 2)
  expect_lt(max_lon_jump(map), 5)
})

test_that("addTrajPaths() adds layerIds and marker colours", {
  one <- dplyr::filter(traj, .data$date == .data$date[[1]])
  cols <- rep(c("red", "blue"), length.out = nrow(one))
  map <- leaflet::leaflet() |>
    addTrajPaths(data = one, layerId = "traj", markerColor = cols, npoints = 24)
  expect_equal(leaflet_calls(map, "addPolylines")[[1]]$args[[2]], "traj-1")
  points <- leaflet_calls(map, "addCircleMarkers")
  expect_length(points, sum(one$hour.inc %% 24 == 0))
  expect_equal(points[[1]]$args[[4]], "traj-1-1")
  expect_equal(points[[1]]$args[[6]]$color, cols[one$hour.inc %% 24 == 0][[1]])

  # vectorised markers can also be coloured
  map <- leaflet::leaflet() |> addTrajPaths(data = one, markerColor = cols)
  expect_equal(
    leaflet_calls(map, "addCircleMarkers")[[1]]$args[[6]]$color,
    cols[one$hour.inc %% 12 == 0]
  )
})

test_that("addTrajPaths() only takes single colours", {
  map <- leaflet::leaflet()
  expect_error(
    addTrajPaths(map, data = traj, color = c("red", "blue")),
    "color"
  )
  expect_error(
    addTrajPaths(map, data = traj, fillColor = c("red", "blue")),
    "fillColor"
  )
})

# addTrajLevel() / trajLevelMap() ----------------------------------------------

test_that("addTrajLevel() adds gridded trajectory frequencies", {
  map <- leaflet::leaflet() |> addTrajLevel(data = traj, layerId = "grid") |> quietly()
  rects <- leaflet_calls(map, "addRectangles")[[1]]
  expect_true(all(grepl("^grid-", rects$args[[5]])))
  legend <- leaflet_legends(map)[[1]]
  expect_equal(legend$title, "percentage<br>trajectories")
})

test_that("addTrajLevel() supports other statistics", {
  map <- leaflet::leaflet() |>
    addTrajLevel(data = traj, pollutant = "nox", statistic = "cwt") |>
    quietly()
  popups <- leaflet_calls(map, "addRectangles")[[1]]$args[[8]]
  expect_true(all(grepl("CWT &middot; NO<sub>x</sub>", popups)))

  # ordinal suffixes, including the "teens" exception
  ordinals <- c("1" = "1st", "12" = "12th", "23" = "23rd")
  for (p in names(ordinals)) {
    map <- leaflet::leaflet() |>
      addTrajLevel(
        data = traj,
        pollutant = "nox",
        statistic = "difference",
        percentile = as.numeric(p),
        legend.title.autotext = FALSE
      ) |>
      quietly()
    expect_match(
      leaflet_legends(map)[[1]]$title,
      paste(ordinals[[p]], "percentile")
    )
  }

  map <- leaflet::leaflet() |>
    addTrajLevel(data = traj, pollutant = "nox", statistic = "pscf") |>
    quietly()
  expect_equal(leaflet_legends(map)[[1]]$title, "PSCF<br>probability")

  expect_error(
    addTrajLevel(leaflet::leaflet(), data = traj, statistic = "cwt"),
    "pollutant"
  )
})

test_that("addTrajLevel() supports breaks, smoothing, type and no legend", {
  map <- leaflet::leaflet() |>
    addTrajLevel(data = traj, breaks = c(0, 1, 10, 100)) |>
    quietly()
  expect_gt(length(leaflet_legends(map)[[1]]$labels), 1)

  map <- leaflet::leaflet() |>
    addTrajLevel(data = traj, smooth = TRUE, legend = FALSE) |>
    quietly()
  expect_length(leaflet_legends(map), 0)
  expect_true(is.na(leaflet_calls(map, "addRectangles")[[1]]$args[[8]]))

  map <- leaflet::leaflet() |>
    addTrajLevel(data = traj, type = "hour", group = "ignored") |>
    quietly()
  groups <- leaflet_calls(map, "addRectangles")[[1]]$args[[6]]
  expect_false("ignored" %in% groups)
  expect_null(leaflet_legends(map)[[1]]$group)
})

test_that("trajLevelMap() makes a map", {
  map <- quietly(trajLevelMap(traj, type = "hour", provider = "cartodark"))
  expect_s3_class(map, "leaflet")
  expect_equal(leaflet_providers(map), "CartoDB.DarkMatter")
  expect_gt(length(layer_control(map)$base), 1)

  map <- quietly(trajLevelMap(traj, pollutant = "nox", statistic = "cwt"))
  expect_null(layer_control(map))
})
