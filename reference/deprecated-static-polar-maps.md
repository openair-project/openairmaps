# Deprecated static directional analysis functions

**\[deprecated\]**

Static direction analysis mapping functions have been deprecated in
favour of combined functions (e.g.,
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)),
which present a more consistent, unified API for users to simply swap
between the two output formats.

## Usage

``` r
polarMapStatic(
  data,
  pollutant = NULL,
  x = "ws",
  limits = "free",
  upper = "fixed",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  facet = NULL,
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

diffMapStatic(
  before,
  after,
  pollutant = NULL,
  limits = "free",
  x = "ws",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  facet = NULL,
  cols = c("#002F70", "#3167BB", "#879FDB", "#C8D2F1", "#F6F6F6", "#F4C8C8", "#DA8A8B",
    "#AE4647", "#5F1415"),
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

annulusMapStatic(
  data,
  pollutant = NULL,
  period = "hour",
  facet = NULL,
  limits = "free",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

windroseMapStatic(
  data,
  ws.int = 2,
  breaks = 4,
  facet = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

pollroseMapStatic(
  data,
  pollutant = NULL,
  statistic = "prop.count",
  breaks = NULL,
  facet = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

percentileMapStatic(
  data,
  pollutant = NULL,
  percentile = c(25, 50, 75, 90, 95),
  intervals = "fixed",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  facet = NULL,
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)

freqMapStatic(
  data,
  pollutant = NULL,
  statistic = "mean",
  breaks = "free",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "osm",
  facet = NULL,
  cols = "turbo",
  alpha = 1,
  key = FALSE,
  facet.nrow = NULL,
  d.icon = 150,
  d.fig = 3,
  ...
)
```

## Arguments

- data:

  *Input data table with pollutant, wind, and geo-spatial information.*

  **required** \| *scope:* dynamic & static

  A data frame. The data frame must contain the data to plot the
  directional analysis marker, which includes wind speed (`ws`), wind
  direction (`wd`), and the column representing the concentration of a
  pollutant. In addition, `data` must include a decimal latitude and
  longitude (or X/Y coordinate used in conjunction with `crs`).

- pollutant:

  *Pollutant name(s).*

  **required** \| *scope:* dynamic & static

  The column name(s) of the pollutant(s) to plot. If multiple pollutants
  are specified and a non-pairwise statistic is supplied, the `type`
  argument will no longer be able to be used and:

  - *Dynamic*: The pollutants can be toggled between using a "layer
    control" menu.

  - *Static:*: The pollutants will each appear in a different panel.

  Multiple `pollutants` prohibit the use of the `type` argument for
  non-pairwise statistics.

- x:

  *The radial axis variable.*

  *default:* `"ws"` \| *scope:* dynamic & static

  The column name for the radial axis variable to use in
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html).
  Defaults to using wind speed, `"ws"`, but other meteorological
  variables such as ambient temperature or atmospheric stability may be
  useful.

- limits:

  *Specifier for the plot colour scale bounds.*

  *default:* `"free"` \| *scope:* dynamic & static

  One of:

  - `"fixed"` which ensures all of the markers use the same colour
    scale.

  - `"free"` (the default) which allows all of the markers to use
    different colour scales.

  - A numeric vector in the form `c(lower, upper)` used to define the
    colour scale. For example, `limits = c(0, 100)` would force the plot
    limits to span 0-100.

- upper:

  *Specifier for the polar plot radial axis upper boundary.*

  *default:* `"fixed"` \| *scope:* dynamic & static

  One of:

  - `"fixed"` (the default) which ensures all of the markers use the
    same radial axis scale.

  - `"free"` which allows all of the markers to use different radial
    axis scales.

  - A numeric value, used as the upper limit for the radial axis scale.

- latitude, longitude:

  *The decimal latitude(Y)/longitude(X).*

  *default:* `NULL` \| *scope:* dynamic & static

  Column names representing the decimal latitude and longitude (or other
  Y/X coordinate if using a different `crs`). If not provided, will be
  automatically inferred from data by looking for a column named
  "lat"/"latitude" or "lon"/"lng"/"long"/"longitude"
  (case-insensitively).

- crs:

  *The coordinate reference system (CRS).*

  *default:* `4326` \| *scope:* dynamic & static

  The coordinate reference system (CRS) of the data, passed to
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html).
  By default this is [EPSG:4326](https://epsg.io/4326), the CRS
  associated with the commonly used latitude and longitude coordinates.
  Different coordinate systems can be specified using `crs` (e.g.,
  `crs = 27700` for the [British National Grid](https://epsg.io/27700)).
  Note that non-lat/lng coordinate systems will be re-projected to
  EPSG:4326 for plotting on the map.

- provider:

  *The basemap(s) to be used.*

  *default:* `"OpenStreetMap"` \| *scope:* dynamic & static

  The base map(s) to be used for the map. If not provided, will default
  to `"OpenStreetMap"`/`"osm"` for both dynamic and static maps.

  - *Dynamic*: Any number of
    [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html).
    See <http://leaflet-extras.github.io/leaflet-providers/preview/> for
    a list of all base maps that can be used. If multiple base maps are
    provided, they can be toggled between using a "layer control"
    interface. By default, the interface will use the provider names as
    labels, but users can define their own using a named vector (e.g.,
    `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`)

  - *Static*: One of the options listed in
    [`rosm::osm.types()`](https://rdrr.io/pkg/rosm/man/deprecated.html)
    (for example, `"osm"`, `"cartodark"`, `"cartolight"`, etc.).

  There is some overlap in static and dynamic providers. For example,
  `{ggspatial}` uses "osm" to specify "OpenStreetMap". When static
  providers are provided to dynamic maps or vice versa, `{openairmaps}`
  will attempt to substitute the correct provider string.

- facet:

  Passed to the `type` argument of the relevant
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family function.

- cols:

  *Colours to use for plotting.*

  *default:* `"turbo"` \| *scope:* dynamic & static

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).
  The default, `"turbo"`, is a rainbow palette with relatively
  perceptually uniform colours.

- alpha:

  *Transparency value for polar markers.*

  *default:* `1` \| *scope:* dynamic & static

  A value between 0 (fully transparent) and 1 (fully opaque).

- key:

  *Draw individual marker legends?*

  *default:* `FALSE` \| *scope:* dynamic & static

  Draw a key for each individual marker? Potentially useful when
  `limits = "free"`, but of limited use otherwise.

- facet.nrow:

  Passed to the `static.nrow` argument of the relevant
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family function.

- d.icon:

  *The diameter of the plot on the map in pixels.*

  *default:* `200` \| *scope:* dynamic & static

  This will affect the size of the individual polar markers.
  Alternatively, a vector in the form `c(width, height)` can be provided
  if a non-circular marker is desired.

- d.fig:

  *The diameter of the plots to be produced using `{openair}` in
  inches.*

  *default:* `3.5` \| *scope:* dynamic & static

  This will affect the resolution of the markers on the map.
  Alternatively, a vector in the form `c(width, height)` can be provided
  if a non-circular marker is desired.

- ...:

  Passed to the polar plotting function

- before, after:

  Data frames representing the "before" and "after" cases. See
  [`polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  for details of different input requirements.

- period:

  *Temporal period for radial axis.*

  *default:* `"hour"` \| *scope:* dynamic & static

  Options are "hour" (the default, to plot diurnal variations), "season"
  to plot variation throughout the year, "weekday" to plot day of the
  week variation and "trend" to plot the trend by wind direction.

- ws.int:

  *The wind speed interval of the colour axis.*

  *default:* `2` \| *scope:* dynamic & static

  The wind speed interval. Default is 2 m/s but for low met masts with
  low mean wind speeds a value of 1 or 0.5 m/s may be better.

- breaks:

  *Specifier for the number of breaks of the colour axis.*

  *default:* `4` \| *scope:* dynamic & static

  Most commonly, the number of break points for wind speed in
  [`openair::windRose()`](https://openair-project.github.io/openair/reference/windRose.html).
  For the `ws.int` default of `2`, the default `breaks`, `4`, generates
  the break points 2, 4, 6, and 8. Breaks can also be used to set
  specific break points. For example, the argument \`breaks = c(0, 1,
  10, 100)“ breaks the data into segments \<1, 1-10, 10-100, \>100.

- statistic:

  *The statistic to be applied to each data bin in the plot*

  *default:* `"prop.mean"` \| *scope:* dynamic & static

  Options currently include `"prop.count"`, `"prop.mean"` and
  `"abs.count"`. `"prop.count"` sizes bins according to the proportion
  of the frequency of measurements. Similarly, `"prop.mean"` sizes bins
  according to their relative contribution to the mean. `"abs.count"`
  provides the absolute count of measurements in each bin.

- percentile:

  *The percentile values for the colour scale bin.*

  *default:* `c(25, 50, 75, 90, 95)` \| *scope:* dynamic & static

  The percentile value(s) to plot using
  [`openair::percentileRose()`](https://openair-project.github.io/openair/reference/percentileRose.html).
  Must be a vector of values between `0` and `100`. If `percentile = NA`
  then only a mean line will be shown.

- intervals:

  *Specifier for the percentile rose radial axis intervals.*

  *default:* `"fixed"` \| *scope:* dynamic & static

  One of:

  - `"fixed"` (the default) which ensures all of the markers use the
    same radial axis scale.

  - `"free"` which allows all of the markers to use different radial
    axis scales.

  - A numeric vector defining a sequence of numbers to use as the
    intervals, e.g., `intervals = c(0, 10, 30, 50)`.

## Value

a `ggplot2` object using
[`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
coordinates with a `ggspatial` basemap

## See also

[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
