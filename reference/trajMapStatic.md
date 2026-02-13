# Trajectory line plots in `ggplot2`

**\[experimental\]**

This function plots back trajectories using `ggplot2`. The function
requires that data are imported using
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).
It is a `ggplot2` implementation of
[`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
with many of the same arguments, which should be more flexible for
post-hoc changes.

## Usage

``` r
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

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL`

  Used for splitting the trajectories into different groups which will
  appear as different panels. Passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

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

- latitude, longitude:

  *The decimal latitude/longitude.*

  *default:* `"lat"` / `"lon"`

  Column names representing the decimal latitude and longitude.

- npoints:

  *Interval at which points are placed along the trajectory paths.*

  *default:* `12`

  A dot is placed every `npoints` along each full trajectory. For hourly
  back trajectories points are plotted every `npoints` hours. This helps
  to understand where the air masses were at particular times and get a
  feel for the speed of the air (points closer together correspond to
  slower moving air masses). Defaults to `12`.

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

- origin:

  *Draw the receptor point as a circle?*

  *default:* `TRUE`

  When `TRUE`, the receptor point(s) are marked with black circles.

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

  `start.day`

  :   What day of the week should the `type = "weekday"` start on? The
      user can change the start day by supplying an integer between 0
      and 6. Sunday = 0, Monday = 1, ... For example to start the
      weekday plots on a Saturday, choose `start.day = 6`.

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

## Value

a `ggplot2` plot

## See also

[`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)

[`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
for the interactive `leaflet` equivalent of `trajMapStatic()`

Other static trajectory maps:
[`trajLevelMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajLevelMapStatic.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# colour by height
trajMapStatic(traj_data) +
  ggplot2::scale_color_gradientn(colors = openair::openColours())

# colour by PM10, log transform scale
trajMapStatic(traj_data, colour = "pm10") +
  ggplot2::scale_color_viridis_c(trans = "log10") +
  ggplot2::labs(color = openair::quickText("PM10"))

# color by PM2.5, lat/lon projection
trajMapStatic(traj_data, colour = "pm2.5", crs = sf::st_crs(4326)) +
  ggplot2::scale_color_viridis_c(option = "turbo") +
  ggplot2::labs(color = openair::quickText("PM2.5"))
} # }
```
