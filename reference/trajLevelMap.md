# Trajectory level plots in `leaflet`

This function plots back trajectories on a `leaflet` map. This function
requires that data are imported using the
[`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html)
function.

## Usage

``` r
trajLevelMap(
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
  cols = "turbo",
  alpha = 0.5,
  tile.border = NA,
  provider = "OpenStreetMap",
  legend.position = "topright",
  legend.title = NULL,
  legend.title.autotext = TRUE,
  control.collapsed = FALSE,
  control.position = "topright"
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
  that, when `smooth = TRUE`, no popup information will be available.

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

## Value

A leaflet object.

## See also

[`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)

[`trajLevelMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajLevelMapStatic.md)
for the static `ggplot2` equivalent of `trajLevelMap()`

Other interactive trajectory maps:
[`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
trajLevelMap(traj_data, pollutant = "pm2.5", statistic = "pscf", min.bin = 10)
} # }
```
