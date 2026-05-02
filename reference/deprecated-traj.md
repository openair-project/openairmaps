# Trajectory plots in `ggplot2`

**\[deprecated\]**

These functions existed at a time when
[`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
and
[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)
were written in `lattice`. Now they are written in `ggplot2`, these
functions have been deprecated and are candidates for future removal.

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
  .combine = NULL,
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

trajMapStatic(
  data,
  colour = "height",
  type = NULL,
  group = NULL,
  size = NULL,
  linewidth = size,
  longitude = "lon",
  latitude = "lat",
  npoints = 12,
  xlim = NULL,
  ylim = NULL,
  crs = sf::st_crs(3812),
  origin = TRUE,
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

  Pollutant (or any numeric column) to be plotted, if any.
  Alternatively, use `group`.

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL`

  Used for splitting the trajectories into different groups which will
  appear as different panels. Passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

- smooth:

  Should the trajectory surface be smoothed? Defaults to `FALSE`. Note
  that smoothing may cause the plot to render slower, so consider
  setting `crs` to `sf::st_crs(4326)` or `NULL`.

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

  *The coordinate reference system (CRS) into which all data should be
  projected before plotting.*

  *default:* `sf::st_crs(3812)`

  This argument defaults to the Lambert projection, but can take any
  coordinate reference system to pass to the `crs` argument of
  [`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  Alternatively, `crs` can be set to `NULL`, which will typically render
  the map quicker but may cause countries far from the equator or large
  areas to appear distorted.

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
  [`ggplot2::coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html),
  [`openair::cutData`](https://openair-project.github.io/openair/reference/cutData.html)

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

  `mapping`

  :   Set of aesthetic mappings created by
      [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
      specified and `inherit.aes = TRUE` (the default), it is combined
      with the default mapping at the top level of the plot. You must
      supply `mapping` if there is no plot mapping.

  `stat`

  :   The statistical transformation to use on the data for this layer.
      When using a `geom_*()` function to construct a layer, the `stat`
      argument can be used to override the default coupling between
      geoms and stats. The `stat` argument accepts the following:

      - A `Stat` ggproto subclass, for example `StatCount`.

      - A string naming the stat. To give the stat as a string, strip
        the function name of the `stat_` prefix. For example, to use
        `stat_count()`, give the stat as `"count"`.

      - For more information and other ways to specify the stat, see the
        [layer
        stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
        documentation.

  `position`

  :   A position adjustment to use on the data for this layer. This can
      be used in various ways, including to prevent overplotting and
      improving the display. The `position` argument accepts the
      following:

      - The result of calling a position function, such as
        `position_jitter()`. This method allows for passing extra
        arguments to the position.

      - A string naming the position adjustment. To give the position as
        a string, strip the function name of the `position_` prefix. For
        example, to use `position_jitter()`, give the position as
        `"jitter"`.

      - For more information and other ways to specify the position, see
        the [layer
        position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
        documentation.

  `na.rm`

  :   If `FALSE`, the default, missing values are removed with a
      warning. If `TRUE`, missing values are silently removed.

  `show.legend`

  :   logical. Should this layer be included in the legends? `NA`, the
      default, includes if any aesthetics are mapped. `FALSE` never
      includes, and `TRUE` always includes.

      You can also set this to one of "polygon", "line", and "point" to
      override the default legend.

  `inherit.aes`

  :   If `FALSE`, overrides the default aesthetics, rather than
      combining with them. This is most useful for helper functions that
      define both data and aesthetics and shouldn't inherit behaviour
      from the default plot specification, e.g.
      [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

  `parse`

  :   If `TRUE`, the labels will be parsed into expressions and
      displayed as described in
      [`?plotmath`](https://rdrr.io/r/grDevices/plotmath.html).

  `label.padding`

  :   Amount of padding around label. Defaults to 0.25 lines.

  `label.r`

  :   Radius of rounded corners. Defaults to 0.15 lines.

  `label.size`

  :   **\[deprecated\]** Replaced by the `linewidth` aesthetic. Size of
      label border, in mm.

  `border.colour,border.color`

  :   Colour of label border. When `NULL` (default), the `colour`
      aesthetic determines the colour of the label border.
      `border.color` is an alias for `border.colour`.

  `text.colour,text.color`

  :   Colour of the text. When `NULL` (default), the `colour` aesthetic
      determines the colour of the text. `text.color` is an alias for
      `text.colour`.

  `fun.geometry`

  :   A function that takes a `sfc` object and returns a `sfc_POINT`
      with the same length as the input. If `NULL`,
      `function(x) sf::st_point_on_surface(sf::st_zm(x))` will be used.
      Note that the function may warn about the incorrectness of the
      result if the data is not projected, but you can ignore this
      except when you really care about the exact locations.

  `check_overlap`

  :   If `TRUE`, text that overlaps previous text in the same layer will
      not be plotted. `check_overlap` happens at draw time and in the
      order of the data. Therefore data should be arranged by the label
      column before calling `geom_text()`. Note that this argument is
      not supported by `geom_label()`.

  `geom`

  :   The geometric object to use to display the data for this layer.
      When using a `stat_*()` function to construct a layer, the `geom`
      argument can be used to override the default coupling between
      stats and geoms. The `geom` argument accepts the following:

      - A `Geom` ggproto subclass, for example `GeomPoint`.

      - A string naming the geom. To give the geom as a string, strip
        the function name of the `geom_` prefix. For example, to use
        `geom_point()`, give the geom as `"point"`.

      - For more information and other ways to specify the geom, see the
        [layer
        geom](https://ggplot2.tidyverse.org/reference/layer_geoms.html)
        documentation.

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

- colour:

  *Data column to map to the colour of the trajectories.*

  *default:* `NULL`

  This column may be numeric, character, factor or date(time). This will
  commonly be a pollutant concentration which has been joined (e.g., by
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html))
  to the trajectory data by "date". The scale can be edited after the
  fact using
  [`ggplot2::scale_color_continuous()`](https://ggplot2.tidyverse.org/reference/scale_colour_continuous.html)
  or similar.

- group:

  *Column to use to distinguish different trajectory paths.*

  *default:* `NULL`

  By default, trajectory paths are distinguished using the arrival date.
  `group` allows for additional columns to be used (e.g., `"receptor"`
  if multiple receptors are being plotted).

- size, linewidth:

  *Data column to map to the size/width of the trajectory marker/paths,
  or absolute size value.*

  *default:* `NULL`

  Similar to the `colour` argument, this defines a column to map to the
  size of the circular markers or the width of the paths. These scales
  can be edited after the fact using
  [`ggplot2::scale_size_continuous()`](https://ggplot2.tidyverse.org/reference/scale_size.html),
  [`ggplot2::scale_linewidth_continuous()`](https://ggplot2.tidyverse.org/reference/scale_linewidth.html),
  or similar. If numeric, the value will be directly provided to
  `ggplot2::geom_point(size = )` or `ggplot2::geom_path(linewidth = )`.

- npoints:

  *Interval at which points are placed along the trajectory paths.*

  *default:* `12`

  A dot is placed every `npoints` along each full trajectory. For hourly
  back trajectories points are plotted every `npoints` hours. This helps
  to understand where the air masses were at particular times and get a
  feel for the speed of the air (points closer together correspond to
  slower moving air masses). Defaults to `12`.

- origin:

  *Draw the receptor point as a circle?*

  *default:* `TRUE`

  When `TRUE`, the receptor point(s) are marked with black circles.
