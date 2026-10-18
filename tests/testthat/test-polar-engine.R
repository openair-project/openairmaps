polar_map_funs <- list(
  polarMap = polarMap,
  annulusMap = annulusMap,
  diffMap = diffMap,
  freqMap = freqMap,
  percentileMap = percentileMap,
  pollroseMap = pollroseMap,
  windroseMap = windroseMap
)

test_that("all polar *Map() functions have the shared arguments", {
  # polar_map_init() reads these from the calling function
  for (name in names(polar_map_funs)) {
    missing <- setdiff(polar_map_args, names(formals(polar_map_funs[[name]])))
    expect(
      length(missing) == 0,
      paste0(name, "() is missing: ", paste(missing, collapse = ", "))
    )
  }
})

# a stand-in for a polar *Map() function
fake_map_fun <- function(
  data,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 1,
  theme = "default",
  key.position = "none",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  control.autotext = TRUE,
  d.icon = 200,
  d.fig = 3.5,
  static = FALSE,
  static.nrow = NULL,
  api_key = NULL,
  progress = TRUE,
  ...,
  control = NULL
) {
  polar_map_init(data, ...)
}

test_that("polar_map_init() collects and checks shared arguments", {
  data <- data.frame(lat = 1, lon = 2)
  map <- suppressMessages(fake_map_fun(data, provider = "osm", alpha = 0.5))
  expect_equal(map$latitude, "lat")
  expect_equal(map$longitude, "lon")
  expect_equal(unname(map$provider), "OpenStreetMap")
  expect_equal(map$legend.position, "topright")
  expect_equal(map$alpha, 0.5)
  expect_null(map$type)

  map <- suppressMessages(fake_map_fun(data, foo = "bar"))
  expect_equal(map$dots, list(foo = "bar"))
})

test_that("polar_map_init() errors for removed `control`/`facet`", {
  data <- data.frame(lat = 1, lon = 2)
  expect_error(fake_map_fun(data, control = "site"), "type")
  expect_error(fake_map_fun(data, facet = "site"), "facet")
  expect_snapshot(fake_map_fun(data, control = "site"), error = TRUE)
  expect_snapshot(
    fake_map_fun(data, control = "site", facet = "site"),
    error = TRUE
  )

  # the real functions get there too
  expect_error(polarMap(data, "nox", control = "site"), "type")
})

test_that("polar_map_prep() splits by pollutant or type", {
  data <- data.frame(
    lat = 1,
    lon = 2,
    wd = c(90, 180),
    ws = 1,
    nox = 1:2,
    no2 = 3:4,
    site = c("a", "b")
  )
  init <- function(...) suppressMessages(fake_map_fun(data, ...))

  map <- polar_map_prep(init(), data, "nox", c("wd", "ws"))
  expect_equal(map$split_col, "pollutant_name")
  expect_equal(map$dropcol, "conc")
  expect_true("conc" %in% names(map$data))

  map <- polar_map_prep(init(type = "site"), data, "nox", c("wd", "ws"))
  expect_equal(map$split_col, "site")
  expect_s3_class(map$data$site, "factor")

  # pairwise statistics aren't pivoted, and aren't faceted by pollutant
  map <- polar_map_prep(
    init(),
    data,
    c("nox", "no2"),
    c("wd", "ws"),
    pairwise = TRUE
  )
  expect_equal(map$split_col, "pollutant_name")
  expect_equal(unique(map$data$pollutant_name), "DUMMY")
  expect_equal(map$dropcol, c("nox", "no2"))
  expect_null(map$pollutant)
})

test_that("polar_fun_args() adds shared arguments", {
  map <- list(
    cols = "viridis",
    theme = "default",
    key.position = "none",
    dots = list(trans = FALSE)
  )
  args <- polar_fun_args(map, list(pollutant = "conc"))
  expect_equal(args$pollutant, "conc")
  expect_false(args$plot)
  expect_equal(args$cols, "viridis")
  expect_false(args$trans)
  expect_false(args$annotate)

  map$dots$annotate <- TRUE
  expect_true(polar_fun_args(map, list())$annotate)
})
