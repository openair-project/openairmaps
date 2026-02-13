# Trajectory level plots in `ggplot2`

**\[experimental\]**

This function plots back trajectories on a `ggplot2` map. This function
requires that data are imported using the
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html)
function. It is a `ggplot2` implementation of
[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)
with many of the same arguments, which should be more flexible for
post-hoc changes.

## Usage

``` r
trajLevelMapStatic(
  data,
  longitude = "lon",
  latitude = "lat",
  pollutant,
  type = NULL,
  smooth = FALSE,
  statistic = "frequency",
  percentile = 90,
  lon.inc = 1,
  lat.inc = 1,
  min.bin = 1,
  .combine = NA,
  sigma = 1.5,
  alpha = 0.5,
  tile.border = NA,
  xlim = NULL,
  ylim = NULL,
  crs = sf::st_crs(4326),
  map = TRUE,
  map.fill = "grey85",
  map.colour = "grey75",
  map.alpha = 0.8,
  map.lwd = 0.5,
  map.lty = 1,
  facet = NULL,
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

  *default:* `"lat"` / `"lon"`

  Column names representing the decimal latitude and longitude.

- pollutant:

  Pollutant to be plotted. By default the trajectory height is used.

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL`

  Used for splitting the trajectories into different groups which can be
  selected between using a "layer control" menu. Passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

- smooth:

  Should the trajectory surface be smoothed? Defaults to `FALSE`. Note
  that smoothing may cause the plot to render slower, so consider
  setting `crs` to `sf::st_crs(4326)` or `NULL`.

- statistic:

  Statistic to use for
  [`trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html).
  By default, the function will plot the trajectory frequencies
  (`statistic = "frequency"`). As an alternative way of viewing
  trajectory frequencies, the argument `method = "hexbin"` can be used.
  In this case hexagonal binning of the trajectory *points* (i.e., a
  point every three hours along each back trajectory). The plot then
  shows the trajectory frequencies uses hexagonal binning.

  There are also various ways of plotting concentrations.

  It is possible to set `statistic = "difference"`. In this case
  trajectories where the associated concentration is greater than
  `percentile` are compared with the the full set of trajectories to
  understand the differences in frequencies of the origin of air masses.
  The comparison is made by comparing the percentage change in gridded
  frequencies. For example, such a plot could show that the top 10\\
  tend to originate from air-mass origins to the east.

  If `statistic = "pscf"` then a Potential Source Contribution Function
  map is produced. This statistic method interacts with `percentile`.

  If `statistic = "cwt"` then concentration weighted trajectories are
  plotted.

  If `statistic = "sqtba"` then Simplified Quantitative Transport Bias
  Analysis is undertaken. This statistic method interacts with
  `.combine` and `sigma`.

- percentile:

  The percentile concentration of `pollutant` against which the all
  trajectories are compared.

- lon.inc, lat.inc:

  The longitude and latitude intervals to be used for binning data.

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

- alpha:

  Opacity of the tiles. Must be between `0` and `1`.

- tile.border:

  Colour to use for the border of binned tiles. Defaults to `NA`, which
  draws no border.

- xlim, ylim:

  *The x- and y-limits of the plot.*

  *default:* `NULL`

  A numeric vector of length two defining the x-/y-limits of the map,
  passed to
  [`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  If `NULL`, limits will be estimated based on the lat/lon ranges of the
  input data.

- crs:

  The coordinate reference system (CRS) into which all data should be
  projected before plotting. Defaults to latitude/longitude
  (`sf::st_crs(4326)`).

- map:

  *Draw a base map?*

  *default:* `TRUE`

  Draws the geometries of countries under the trajectory paths.

- map.fill:

  *Colour to use to fill the polygons of the base map.*

  *default:* `"grey85"`

  See [`colors()`](https://rdrr.io/r/grDevices/colors.html) for colour
  options. Alternatively, a hexadecimal color code can be provided.

- map.colour:

  *Colour to use for the polygon borders of the base map.*

  *default:* `"grey75"`

  See [`colors()`](https://rdrr.io/r/grDevices/colors.html) for colour
  options. Alternatively, a hexadecimal color code can be provided.

- map.alpha:

  *Transparency of the base map polygons.*

  *default:* `0.8`

  Must be between `0` (fully transparent) and `1` (fully opaque).

- map.lwd:

  *Line width of the base map polygon borders.*

  *default:* `0.5`

  Any numeric value.

- map.lty:

  *Line type of the base map polygon borders.*

  *default:* `1`

  See
  [`ggplot2::scale_linetype()`](https://ggplot2.tidyverse.org/reference/scale_linetype.html)
  for common examples. The default, `1`, draws solid lines.

- facet:

  Deprecated. Please use `type`.

- ...:

  Arguments passed on to
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html)

  `expand`

  :   If `TRUE`, the default, adds a small expansion factor to the
      limits to ensure that data and axes don't overlap. If `FALSE`,
      limits are taken exactly from the data or `xlim`/`ylim`. Giving a
      logical vector will separately control the expansion for the four
      directions (top, left, bottom and right). The `expand` argument
      will be recycled to length 4 if necessary. Alternatively, can be a
      named logical vector to control a single direction, e.g.
      `expand = c(bottom = FALSE)`.

  `datum`

  :   CRS that provides datum to use when generating graticules.

  `label_graticule`

  :   Character vector indicating which graticule lines should be
      labeled where. Meridians run north-south, and the letters `"N"`
      and `"S"` indicate that they should be labeled on their north or
      south end points, respectively. Parallels run east-west, and the
      letters `"E"` and `"W"` indicate that they should be labeled on
      their east or west end points, respectively. Thus,
      `label_graticule = "SW"` would label meridians at their south end
      and parallels at their west end, whereas `label_graticule = "EW"`
      would label parallels at both ends and meridians not at all.
      Because meridians and parallels can in general intersect with any
      side of the plot panel, for any choice of `label_graticule` labels
      are not guaranteed to reside on only one particular side of the
      plot panel. Also, `label_graticule` can cause labeling artifacts,
      in particular if a graticule line coincides with the edge of the
      plot panel. In such circumstances, `label_axes` will generally
      yield better results and should be used instead.

      This parameter can be used alone or in combination with
      `label_axes`.

  `label_axes`

  :   Character vector or named list of character values specifying
      which graticule lines (meridians or parallels) should be labeled
      on which side of the plot. Meridians are indicated by `"E"` (for
      East) and parallels by `"N"` (for North). Default is `"--EN"`,
      which specifies (clockwise from the top) no labels on the top,
      none on the right, meridians on the bottom, and parallels on the
      left. Alternatively, this setting could have been specified with
      `list(bottom = "E", left = "N")`.

      This parameter can be used alone or in combination with
      `label_graticule`.

  `lims_method`

  :   Method specifying how scale limits are converted into limits on
      the plot region. Has no effect when `default_crs = NULL`. For a
      very non-linear CRS (e.g., a perspective centered around the North
      pole), the available methods yield widely differing results, and
      you may want to try various options. Methods currently implemented
      include `"cross"` (the default), `"box"`, `"orthogonal"`, and
      `"geometry_bbox"`. For method `"cross"`, limits along one
      direction (e.g., longitude) are applied at the midpoint of the
      other direction (e.g., latitude). This method avoids excessively
      large limits for rotated coordinate systems but means that
      sometimes limits need to be expanded a little further if extreme
      data points are to be included in the final plot region. By
      contrast, for method `"box"`, a box is generated out of the limits
      along both directions, and then limits in projected coordinates
      are chosen such that the entire box is visible. This method can
      yield plot regions that are too large. Finally, method
      `"orthogonal"` applies limits separately along each axis, and
      method `"geometry_bbox"` ignores all limit information except the
      bounding boxes of any objects in the `geometry` aesthetic.

  `ndiscr`

  :   Number of segments to use for discretising graticule lines; try
      increasing this number when graticules look incorrect.

  `default`

  :   Is this the default coordinate system? If `FALSE` (the default),
      then replacing this coordinate system with another one creates a
      message alerting the user that the coordinate system is being
      replaced. If `TRUE`, that warning is suppressed.

  `clip`

  :   Should drawing be clipped to the extent of the plot panel? A
      setting of `"on"` (the default) means yes, and a setting of
      `"off"` means no. In most cases, the default of `"on"` should not
      be changed, as setting `clip = "off"` can cause unexpected
      results. It allows drawing of data points anywhere on the plot,
      including in the plot margins. If limits are set via `xlim` and
      `ylim` and some data points fall outside those limits, then those
      data points may show up in places such as the axes, the legend,
      the plot title, or the plot margins.

  `reverse`

  :   A string giving which directions to reverse. `"none"` (default)
      keeps directions as is. `"x"` and `"y"` can be used to reverse
      their respective directions. `"xy"` can be used to reverse both
      directions.

## Value

A `ggplot2` plot

## See also

[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)

[`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
for the interactive `leaflet` equivalent of `trajLevelMapStatic()`

Other static trajectory maps:
[`trajMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajMapStatic.md)
