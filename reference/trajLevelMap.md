# Trajectory level plots in `leaflet`

This function plots back trajectories on a `leaflet` map. This function
requires that data are imported using the
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html)
function.

## Usage

``` r
trajLevelMap(
  data,
  latitude = NULL,
  longitude = NULL,
  pollutant = NULL,
  type = NULL,
  smooth = FALSE,
  statistic = "frequency",
  percentile = 90,
  lon.inc = 1,
  lat.inc = 1,
  breaks = NULL,
  min.bin = 1,
  .combine = NULL,
  sigma = 1.5,
  cols = "turbo",
  alpha = 0.5,
  tile.border = NA,
  provider = "OpenStreetMap",
  legend.position = "topright",
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  ...
)
```

## Arguments

- data:

  *A data frame containing a HYSPLIT trajectory, perhaps accessed with
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).*

  **required**

  A data frame containing HYSPLIT model outputs. If this data were not
  obtained using
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).

- latitude, longitude:

  *The decimal latitude/longitude.*

  *default:* `NULL`

  Column names representing the decimal latitude and longitude. If not
  provided, will be automatically inferred from data by looking for a
  column named "lat"/"latitude" or "lon"/"lng"/"long"/"longitude"
  (case-insensitively), such as the "lat" and "lon" columns returned by
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).

- pollutant:

  The pollutant of interest. Not required when
  `statistic = "frequency"`.

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL`

  Used for splitting the trajectories into different groups which can be
  selected between using a "layer control" menu. Passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

- smooth:

  Should the trajectory surface be smoothed? Defaults to `FALSE`. Note
  that, when `smooth = TRUE`, no popup information will be available.

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

- cols:

  *Colours to use for plotting.*

  *default:* `"turbo"`

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).

- alpha:

  *Transparency value for trajectories.*

  *default:* `0.5`

  A value between `0` (fully transparent) and `1` (fully opaque).

- tile.border:

  Colour to use for the border of binned tiles. Defaults to `NA`, which
  draws no border.

- provider:

  *The basemap(s) to be used.*

  *default:* `"OpenStreetMap"`

  Any number of
  [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html).
  See <http://leaflet-extras.github.io/leaflet-providers/preview/> for a
  list of all base maps that can be used. If multiple base maps are
  provided, they can be toggled between using a "layer control"
  interface. By default, the interface will use the provider names as
  labels, but users can define their own using a named vector (e.g.,
  `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`)

- legend.position:

  *Position of the shared legend.*

  *default:* `"topright"`

  Where should the legend be placed? One of "topright", "topleft",
  "bottomleft" or "bottomright". Passed to the `position` argument of
  [`leaflet::addLegend()`](https://rstudio.github.io/leaflet/reference/addLegend.html).
  `NULL` defaults to "topright".

- legend.title:

  *Title of the legend.*

  *default:* `NULL`

  By default, when `legend.title = NULL`, the function will attempt to
  provide a sensible legend title based on `colour`. `legend.title`
  allows users to overwrite this - for example, to include units or
  other contextual information. Users may wish to use HTML tags to
  format the title.

- legend.title.autotext:

  *Automatically format the title of the legend?*

  *default:* `TRUE`

  When `legend.title.autotext = TRUE`, `legend.title` will be first run
  through
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md).

- control.collapsed:

  *Show the layer control as a collapsed?*

  *default:* `FALSE`

  Should the "layer control" interface be collapsed? If `TRUE`, users
  will have to hover over an icon to view the options.

- control.position:

  *Position of the layer control menu*

  *default:* `"topright"`

  Where should the "layer control" interface be placed? One of
  "topleft", "topright", "bottomleft" or "bottomright". Passed to the
  `position` argument of
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html).

- ...:

  Arguments passed on to
  [`openair::cutData`](https://openair-project.github.io/openair/reference/cutData.html)

  `names`

  :   By default, the columns created by
      [`cutData()`](https://openair-project.github.io/openair/reference/cutData.html)
      are named after their `type` option. Specifying `names` defines
      other names for the columns, which map onto the `type` options in
      the same order they are given. The length of `names` should
      therefore be equal to the length of `type`.

  `suffix`

  :   If `name` is not specified, `suffix` will be appended to any added
      columns that would otherwise overwrite existing columns. For
      example, `cutData(mydata, "nox", suffix = "_cuts")` would append a
      `nox_cuts` column rather than overwriting `nox`.

  `hemisphere`

  :   Can be `"northern"` or `"southern"`, used to split data into
      seasons.

  `n.levels`

  :   Number of quantiles to split numeric data into.

  `wd.res`

  :   The number of wind direction bins; one of `4` (N/E/S/W), `8`
      (N/NE/E/SE/etc., the default) or `16` (N/NNE/NE/ENE/etc.).

  `start.day`

  :   What day of the week should the `type = "weekday"` start on? The
      user can change the start day by supplying an integer between 0
      and 6. Sunday = 0, Monday = 1, ... For example to start the
      weekday plots on a Saturday, choose `start.day = 6`.

  `start.season`

  :   What order should the season be. By default, the order is spring,
      summer, autumn, winter. `start.season = "winter"` would plot
      winter first.

  `is.axis`

  :   A logical (`TRUE`/`FALSE`), used to request shortened cut labels
      for axes.

  `local.tz`

  :   Used for identifying whether a date has daylight savings time
      (DST) applied or not. Examples include
      `local.tz = "Europe/London"`, `local.tz = "America/New_York"`,
      i.e., time zones that assume DST.
      <https://en.wikipedia.org/wiki/List_of_zoneinfo_time_zones> shows
      time zones that should be valid for most systems. It is important
      that the original data are in GMT (UTC) or a fixed offset from
      GMT.

  `latitude,longitude`

  :   The decimal latitude and longitudes used when `type = "daylight"`.
      Note that locations west of Greenwich have negative longitudes.

  `drop`

  :   How to handle empty factor levels. One of:

      - `"default"`: Sensible defaults selected on a case-by-case basis
        for different `type` options.

      - `"empty"`: Drop all empty factor levels.

      - `"none"`: Retain all empty factor levels, where possible. For
        example, for `type = "hour"`, all factor levels from `0` and
        `23` will be represented.

      - `"outside"`: Retain empty factor levels within the range of the
        data. For example, for `type = "hour"` when the data only
        contains data for 1 AM and 5 AM, the factor levels, `1`, `2`,
        `3`, `4` and `5` will be retained.

      Some of these options only apply to certain `type` options. For
      example, for `type = "year"`, `"outside"` is equivalent to
      `"none"` as there is no fixed range of years to use in the
      `"none"` case.

## Value

A leaflet object.

## See also

[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)

[`addTrajLevel()`](https://openair-project.github.io/openairmaps/reference/addTrajLevel.md)
to add gridded trajectory statistics to any leaflet map

Other interactive trajectory maps:
[`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
trajLevelMap(traj_data, pollutant = "pm2.5", statistic = "pscf", min.bin = 10)
} # }
```
