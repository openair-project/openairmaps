# Trajectory line plots in `leaflet`

This function plots back trajectories on a `leaflet` map. This function
requires that data are imported using the
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html)
function. Options are provided to colour the individual trajectories
(e.g., by pollutant concentrations) or create "layer control" menus to
show/hide different layers.

## Usage

``` r
trajMap(
  data,
  longitude = "lon",
  latitude = "lat",
  colour = NULL,
  type = NULL,
  cols = "default",
  alpha = 0.5,
  npoints = 12,
  provider = "OpenStreetMap",
  legend.position = "topright",
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright",
  control = NULL,
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

- colour:

  *Column to be used for colouring each trajectory.*

  *default:* `NULL`

  This column may be numeric, character, factor or date(time). This will
  commonly be a pollutant concentration which has been joined (e.g., by
  [`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html))
  to the trajectory data by "date".

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL`

  Used for splitting the trajectories into different groups which can be
  selected between using a "layer control" menu. Passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

- cols:

  *Colours to use for plotting.*

  *default:* `"default"`

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).

- alpha:

  *Transparency value for trajectories.*

  *default:* `1`

  A value between `0` (fully transparent) and `1` (fully opaque).

- npoints:

  *Interval at which points are placed along the trajectory paths.*

  *default:* `12`

  A dot is placed every `npoints` along each full trajectory. For hourly
  back trajectories points are plotted every `npoints` hours. This helps
  to understand where the air masses were at particular times and get a
  feel for the speed of the air (points closer together correspond to
  slower moving air masses). Defaults to `12`.

- provider:

  *The basemap to be used.*

  *default:* `"OpenStreetMap"`

  A single
  [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html).
  See <http://leaflet-extras.github.io/leaflet-providers/preview/> for a
  list of all base maps that can be used.

- legend.position:

  *Position of the shared legend.*

  *default:* `"topright"`

  Where should the legend be placed? One of "topright", "topright",
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

- control:

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

A leaflet object.

## See also

[`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)

[`trajMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajMapStatic.md)
for the static `ggplot2` equivalent of `trajMap()`

Other interactive trajectory maps:
[`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
trajMap(traj_data, colour = "pm10")
} # }
```
