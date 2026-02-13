# Add polar markers to leaflet map

This function is similar (but not identical to) the
[`leaflet::addMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
and
[`leaflet::addCircleMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
functions in `leaflet`, which allows users to add `openair` directional
analysis plots to any leaflet map and have more control over groups and
layerIds than in "all-in-one" functions like
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).

## Usage

``` r
addPolarMarkers(
  map,
  pollutant,
  fun = openair::polarPlot,
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = leaflet::markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  key = FALSE,
  d.icon = 200,
  d.fig = 3.5,
  data = leaflet::getMapData(map),
  ...
)

addPolarDiffMarkers(
  map,
  pollutant,
  before = leaflet::getMapData(map),
  after = leaflet::getMapData(map),
  lng = NULL,
  lat = NULL,
  layerId = NULL,
  group = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = leaflet::markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  key = FALSE,
  d.icon = 200,
  d.fig = 3.5,
  ...
)
```

## Arguments

- map:

  a map widget object created from
  [`leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)

- pollutant:

  The name of the pollutant to be plot. Note that, if
  `fun = openair::windRose`, you must set `pollutant = "ws"`.

- fun:

  An `openair` directional analysis plotting function. Supported
  functions include
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  (the default),
  [`openair::polarAnnulus()`](https://openair-project.github.io/openair/reference/polarAnnulus.html),
  [`openair::polarFreq()`](https://openair-project.github.io/openair/reference/polarFreq.html),
  [`openair::percentileRose()`](https://openair-project.github.io/openair/reference/percentileRose.html),
  [`openair::pollutionRose()`](https://openair-project.github.io/openair/reference/pollutionRose.html)
  and
  [`openair::windRose()`](https://openair-project.github.io/openair/reference/windRose.html).
  For
  [`openair::polarDiff()`](https://openair-project.github.io/openair/reference/polarDiff.html),
  use `addPolarDiffMarkers()`.

- lng:

  The decimal longitude.

- lat:

  The decimal latitude.

- layerId:

  the layer id

- group:

  the name of the group the newly created layers should belong to (for
  [`clearGroup()`](https://rstudio.github.io/leaflet/reference/remove.html)
  and
  [`addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html)
  purposes). Human-friendly group names are permitted–they need not be
  short, identifier-style names. Any number of layers and even different
  types of layers (e.g., markers and polygons) can share the same group
  name.

- popup:

  A column of `data` to be used as a popup.

- popupOptions:

  A Vector of
  [`popupOptions()`](https://rstudio.github.io/leaflet/reference/map-options.html)
  to provide popups

- label:

  A column of `data` to be used as a label.

- labelOptions:

  A Vector of
  [`labelOptions()`](https://rstudio.github.io/leaflet/reference/map-options.html)
  to provide label options for each label. Default `NULL`

- options:

  a list of extra options for tile layers, popups, paths (circles,
  rectangles, polygons, ...), or other map elements

- clusterOptions:

  if not `NULL`, markers will be clustered using
  [Leaflet.markercluster](https://github.com/Leaflet/Leaflet.markercluster);
  you can use
  [`markerClusterOptions()`](https://rstudio.github.io/leaflet/reference/map-options.html)
  to specify marker cluster options

- clusterId:

  the id for the marker cluster layer

- key:

  Should a key for each marker be drawn? Default is `FALSE`.

- d.icon:

  The diameter of the plot on the map in pixels. This will affect the
  size of the individual polar markers. Alternatively, a vector in the
  form `c(width, height)` can be provided if a non-circular marker is
  desired.

- d.fig:

  The diameter of the plots to be produced using `openair` in inches.
  This will affect the resolution of the markers on the map.
  Alternatively, a vector in the form `c(width, height)` can be provided
  if a non-circular marker is desired.

- data:

  A data frame. The data frame must contain the data to plot your choice
  of openair directional analysis plot, which includes wind speed
  (`ws`), wind direction (`wd`), and the column representing the
  concentration of a pollutant. In addition, `data` must include a
  decimal latitude and longitude. By default, it is the data object
  provided to
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
  initially, but can be overridden.

- ...:

  Other arguments for the plotting function (e.g. `period` for
  [`openair::polarAnnulus()`](https://openair-project.github.io/openair/reference/polarAnnulus.html)).

- before, after:

  A data frame that represents the before/after case. See
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  for details of different input requirements. By default, both `before`
  and `after` are the data object provided to
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
  initially, but at least one should be overridden.

## Value

A leaflet object.

## Functions

- `addPolarMarkers()`: Add any one-table polar marker (e.g.,
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html))

- `addPolarDiffMarkers()`: Add the two-table
  [`openair::polarDiff()`](https://openair-project.github.io/openair/reference/polarDiff.html)
  marker.

## See also

`shiny::runExample(package = "openairmaps")` to see examples of this
function used in a
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html)

## Examples

``` r
if (FALSE) { # \dontrun{
library(leaflet)
library(openair)

# different types of polar plot on one map
leaflet(data = polar_data) |>
  addTiles() |>
  addPolarMarkers(
    "ws",
    fun = openair::windRose,
    annotate = FALSE,
    group = "Wind Rose"
  ) |>
  addPolarMarkers("nox", fun = openair::polarPlot, group = "Polar Plot") |>
  addLayersControl(
    baseGroups = c("Wind Rose", "Polar Plot")
  )

# use of polar diff (NB: both 'before' and 'after' inherit from `leaflet()`,
# so at least one should be overridden - in this case 'after')
leaflet(data = polar_data) |>
  addTiles() |>
  addPolarDiffMarkers("nox",
    after = dplyr::mutate(polar_data, nox = jitter(nox, 5))
  )
} # }
```
