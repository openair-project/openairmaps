# Add gridded trajectory statistics to leaflet map

This function is similar (but not identical to) the
[`leaflet::addRectangles()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
function in `leaflet`, which allows users to add gridded trajectory
statistics (calculated using
[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html))
to any leaflet map and have more control over groups and layerIds than
in "all-in-one" functions like
[`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md).

## Usage

``` r
addTrajLevel(
  map,
  data = leaflet::getMapData(map),
  lng = "lon",
  lat = "lat",
  pollutant = NULL,
  statistic = "frequency",
  percentile = 90,
  lon.inc = 1,
  lat.inc = 1,
  breaks = NULL,
  min.bin = 1,
  .combine = NULL,
  sigma = 1.5,
  smooth = FALSE,
  type = NULL,
  cols = "turbo",
  alpha = 0.5,
  tile.border = NA,
  layerId = NULL,
  group = NULL,
  legend = TRUE,
  legend.position = "topright",
  legend.title = NULL,
  legend.title.autotext = TRUE,
  ...
)
```

## Arguments

- map:

  a map widget object created from
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html).

- data:

  Data frame, the result of importing a trajectory file using
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).
  By default, it is the data object provided to
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
  initially, but can be overridden.

- lng:

  The decimal longitude.

- lat:

  The decimal latitude.

- pollutant:

  The pollutant of interest. Not required when
  `statistic = "frequency"`.

- statistic:

  One of:

  - `"frequency"` (the default) shows trajectory frequencies.

  - `"hexbin"`, which is similar to `"frequency"` but shows a hexagonal
    grid of counts.

  - `"difference"` - in this case trajectories where the associated
    concentration is greater than `percentile` are compared with the the
    full set of trajectories to understand the differences in
    frequencies of the origin of air masses. The comparison is made by
    comparing the percentage change in gridded frequencies. For example,
    such a plot could show that the top 10\\ to the east.

  - `"pscf"` for a Potential Source Contribution Function map. This
    statistic method interacts with `percentile`.

  - `"cwt"` for concentration weighted trajectories.

  - `"sqtba"` to undertake Simplified Quantitative Transport Bias
    Analysis. This statistic method interacts with `.combine` and
    `sigma`.

- percentile:

  The percentile concentration of `pollutant` against which the all
  trajectories are compared.

- lon.inc, lat.inc:

  The longitude and latitude intervals to be used for binning data. If
  `statistic = "hexbin"`, the minimum value out of of `lon.inc` and
  `lat.inc` is passed to the `binwidth` argument of
  [`ggplot2::geom_hex()`](https://ggplot2.tidyverse.org/reference/geom_hex.html).

- breaks:

  `breaks` bins a continuous axis into discrete bins. It can either take
  a single number (e.g., `breaks = 5`) to split the scale into
  quantiles, a vector of numbers (e.g.,
  `breaks = c(0, 50, 100, 200, 500`) to define specific break-points, or
  a named list. See
  [`breakOpts()`](https://openair-project.github.io/openair/reference/breakOpts.html)
  for more details. Note that, in
  [`trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html),
  each `statistic` provides a different default break strategy; to
  override those that bin the limits by default (e.g., `"frequency"`),
  pass `breaks = NULL` explicitly.

- min.bin:

  The minimum number of unique points in a grid cell. Counts below
  `min.bin` are set as missing.

- .combine:

  When statistic is "SQTBA" it is possible to combine lots of receptor
  locations to derive a single map. `.combine` identifies the column
  that differentiates different sites (commonly a column named
  `"site"`). Note that individual site maps are normalised first by
  dividing by their mean value.

- sigma:

  For the SQTBA approach `sigma` determines the amount of back
  trajectory spread based on the Gaussian plume equation. Values in the
  literature suggest 5.4 km after one hour. However, testing suggests
  lower values reveal source regions more effectively while not
  introducing too much noise.

- smooth:

  Should the trajectory surface be smoothed? Defaults to `FALSE`. Note
  that, when `smooth = TRUE`, no popup information will be available.

- type:

  Optionally, a method to condition the `data`, passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).
  Each level of `type` is added to the map as its own `group` (sharing a
  single colour scale), so can be toggled between using
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html).
  If `type` is provided, `group` is ignored.

- cols:

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).
  The default, `"turbo"`, is a rainbow palette with relatively
  perceptually uniform colours.

- alpha:

  Opacity of the tiles. Must be between `0` and `1`.

- tile.border:

  Colour to use for the border of binned tiles. Defaults to `NA`, which
  draws no border.

- layerId:

  The base string for the layer id. The actual layer IDs will be in the
  format "layerId-tilenum". For example, the first tile will be
  "layerId-1".

- group:

  the name of the group the newly created layers should belong to (for
  [`leaflet::clearGroup()`](https://rstudio.github.io/leaflet/reference/remove.html)
  and
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html)
  purposes). Human-friendly group names are permitted–they need not be
  short, identifier-style names. Any number of layers and even different
  types of layers (e.g. markers and polygons) can share the same group
  name.

- legend:

  Should a legend be added to the map? Defaults to `TRUE`. When `type`
  is not used, the legend is given the same `group` as the tiles, so it
  is shown and hidden alongside them.

- legend.position:

  Where should the legend be placed? One of "topright", "topleft",
  "bottomleft" or "bottomright". Passed to the `position` argument of
  [`leaflet::addLegend()`](https://rstudio.github.io/leaflet/reference/addLegend.html).

- legend.title:

  Title of the legend. By default, when `legend.title = NULL`, the
  function will attempt to provide a sensible legend title based on
  `statistic`. `legend.title` allows users to overwrite this - for
  example, to include units or other contextual information. Users may
  wish to use HTML tags to format the title.

- legend.title.autotext:

  When `legend.title.autotext = TRUE`, `legend.title` will be first run
  through
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md).

- ...:

  Other arguments to pass to
  [`leaflet::addRectangles()`](https://rstudio.github.io/leaflet/reference/map-layers.html).
  These will override any defaults set by `addTrajLevel()` (e.g.,
  `weight`).

## Value

A leaflet object.

## See also

[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)

## Examples

``` r
if (FALSE) { # \dontrun{
library(leaflet)

leaflet() |>
  addTiles() |>
  addTrajLevel(
    data = traj_data,
    pollutant = "pm2.5",
    statistic = "pscf",
    min.bin = 10,
    group = "PSCF"
  ) |>
  addLayersControl(overlayGroups = "PSCF")
} # }
```
