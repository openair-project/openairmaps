# Polar annulus plots on dynamic and static maps

The `annulusMap()` function creates a map using polar annulus plots as
markers. Any number of pollutants can be specified using the `pollutant`
argument, and multiple layers of markers can be created using `type`. By
default, these maps are dynamic and can be panned, zoomed, and otherwise
interacted with. Using the `static` argument allows for static images to
be produced instead.

## Usage

``` r
annulusMap(
  data,
  pollutant = NULL,
  period = "hour",
  limits = "free",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 1,
  key = FALSE,
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
  progress = TRUE,
  ...,
  control = NULL
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

- period:

  *Temporal period for radial axis.*

  *default:* `"hour"` \| *scope:* dynamic & static

  Options are "hour" (the default, to plot diurnal variations), "season"
  to plot variation throughout the year, "weekday" to plot day of the
  week variation and "trend" to plot the trend by wind direction.

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

- type:

  *A method to condition the `data` for separate plotting.*

  *default:* `NULL` \| *scope:* dynamic & static

  Used for splitting the input data into different groups, passed to the
  `type` argument of
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).
  When `type` is specified:

  - *Dynamic*: The different data splits can be toggled between using a
    "layer control" menu.

  - *Static:*: The data splits will each appear in a different panel.

  `type` cannot be used if multiple `pollutant` columns have been
  provided.

- popup:

  *Content for marker popups on dynamic maps.*

  *default:* `NULL` \| *scope:* dynamic

  Columns to be used as the HTML content for marker popups on dynamic
  maps. Popups may be useful to show information about the individual
  sites (e.g., site names, codes, types, etc.). If a vector of column
  names are provided they are passed to
  [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  using its default values.

- label:

  *Content for marker hover-over on dynamic maps.*

  *default:* `NULL` \| *scope:* dynamic

  Column to be used as the HTML content for hover-over labels. Labels
  are useful for the same reasons as popups, though are typically
  shorter.

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

  - *Static*: One of
    [`rosm::osm.types()`](https://rdrr.io/pkg/rosm/man/deprecated.html).

  There is some overlap in static and dynamic providers. For example,
  `{ggspatial}` uses "osm" to specify "OpenStreetMap". When static
  providers are provided to dynamic maps or vice versa, `{openairmaps}`
  will attempt to substitute the correct provider string.

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

- legend:

  *Draw a shared legend?*

  *default:* `TRUE` \| *scope:* dynamic & static

  When all markers share the same colour scale (e.g., when
  `limits != "free"` in
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)),
  should a shared legend be created at the side of the map?

- legend.position:

  *Position of the shared legend.*

  *default:* `NULL` \| *scope:* dynamic & static

  When `legend = TRUE`, where should the legend be placed?

  - *Dynamic*: One of "topright", "topright", "bottomleft" or
    "bottomright". Passed to the `position` argument of
    [`leaflet::addLegend()`](https://rstudio.github.io/leaflet/reference/addLegend.html).

  - *Static:*: One of "top", "right", "bottom" or "left". Passed to the
    `legend.position` argument of
    [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html).

- legend.title:

  *Title of the legend.*

  *default:* `NULL` \| *scope:* dynamic & static

  By default, when `legend.title = NULL`, the function will attempt to
  provide a sensible legend title. `legend.title` allows users to
  overwrite this - for example, to include units or other contextual
  information. For *dynamic* maps, users may wish to use HTML tags to
  format the title.

- legend.title.autotext:

  *Automatically format the title of the legend?*

  *default:* `TRUE` \| *scope:* dynamic & static

  When `legend.title.autotext = TRUE`, `legend.title` will be first run
  through
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)
  (*dynamic*) or
  [`openair::quickText()`](https://openair-project.github.io/openair/reference/quickText.html)
  (*static*).

- control.collapsed:

  *Show the layer control as a collapsed?*

  *default:* `FALSE` \| *scope:* dynamic

  For *dynamic* maps, should the "layer control" interface be collapsed?
  If `TRUE`, users will have to hover over an icon to view the options.

- control.position:

  *Position of the layer control menu*

  *default:* `"topright"` \| *scope:* dynamic

  When `type != NULL`, or multiple pollutants are specified, where
  should the "layer control" interface be placed? One of "topleft",
  "topright", "bottomleft" or "bottomright". Passed to the `position`
  argument of
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html).

- control.autotext:

  *Automatically format the content of the layer control menu?*

  *default:* `TRUE` \| *scope:* dynamic

  When `control.autotext = TRUE`, the content of the "layer control"
  interface will be first run through
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md).

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

- static:

  *Produce a static map?*

  *default:* `FALSE`

  This controls whether a *dynamic* or *static* map is produced. The
  former is the default and is broadly more useful, but the latter may
  be preferable for DOCX or PDF outputs (e.g., academic papers).

- static.nrow:

  *Number of rows in a static map.*

  *default:* `NULL` \| *scope:* static

  Controls the number of rows of panels on a static map when multiple
  `pollutant`s or `type` are specified; passed to the `nrow` argument of
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).
  The default, `NULL`, results in a roughly square grid of panels.

- progress:

  *Show a progress bar?*

  *default:* `TRUE` \| *scope:* dynamic & static

  By default, a progress bar is shown to visualise the function's
  progress creating individual polar markers. This option allows this to
  be turned off, if desired.

- ...:

  Arguments passed on to
  [`openair::polarAnnulus`](https://openair-project.github.io/openair/reference/polarAnnulus.html)

  `resolution`

  :   Two plot resolutions can be set: “normal” and “fine” (the
      default).

  `local.tz`

  :   Should the results be calculated in local time that includes a
      treatment of daylight savings time (DST)? The default is not to
      consider DST issues, provided the data were imported without a DST
      offset. Emissions activity tends to occur at local time e.g. rush
      hour is at 8 am every day. When the clocks go forward in spring,
      the emissions are effectively released into the atmosphere
      typically 1 hour earlier during the summertime i.e. when DST
      applies. When plotting diurnal profiles, this has the effect of
      “smearing-out” the concentrations. Sometimes, a useful approach is
      to express time as local time. This correction tends to produce
      better-defined diurnal profiles of concentration (or other
      variables) and allows a better comparison to be made with
      emissions/activity data. If set to `FALSE` then GMT is used.
      Examples of usage include `local.tz = "Europe/London"`,
      `local.tz = "America/New_York"`. See `cutData` and `import` for
      more details.

  `statistic`

  :   The statistic that should be applied to each wind speed/direction
      bin. Can be “mean” (default), “median”, “max” (maximum),
      “frequency”. “stdev” (standard deviation), “weighted.mean” or
      “cpf” (Conditional Probability Function). Because of the smoothing
      involved, the colour scale for some of these statistics is only to
      provide an indication of overall pattern and should not be
      interpreted in concentration units e.g. for
      `statistic = "weighted.mean"` where the bin mean is multiplied by
      the bin frequency and divided by the total frequency. In many
      cases using `polarFreq` will be better. Setting
      `statistic = "weighted.mean"` can be useful because it provides an
      indication of the concentration \* frequency of occurrence and
      will highlight the wind speed/direction conditions that dominate
      the overall mean.

  `percentile`

  :   If `statistic = "percentile"` or `statistic = "cpf"` then
      `percentile` is used, expressed from 0 to 100. Note that the
      percentile value is calculated in the wind speed, wind direction
      ‘bins’. For this reason it can also be useful to set `min.bin` to
      ensure there are a sufficient number of points available to
      estimate a percentile. See `quantile` for more details of how
      percentiles are calculated.

  `width`

  :   The width of the annulus; can be “normal” (the default), “thin” or
      “fat”.

  `min.bin`

  :   The minimum number of points allowed in a wind speed/wind
      direction bin. The default is 1. A value of two requires at least
      2 valid records in each bin an so on; bins with less than 2 valid
      records are set to NA. Care should be taken when using a value \>
      1 because of the risk of removing real data points. It is
      recommended to consider your data with care. Also, the `polarFreq`
      function can be of use in such circumstances.

  `exclude.missing`

  :   Setting this option to `TRUE` (the default) removes points from
      the plot that are too far from the original data. The smoothing
      routines will produce predictions at points where no data exist
      i.e. they predict. By removing the points too far from the
      original data produces a plot where it is clear where the original
      data lie. If set to `FALSE` missing data will be interpolated.

  `date.pad`

  :   For `type = "trend"` (default), `date.pad = TRUE` will pad-out
      missing data to the beginning of the first year and the end of the
      last year. The purpose is to ensure that the trend plot begins and
      ends at the beginning or end of year.

  `force.positive`

  :   The default is `TRUE`. Sometimes if smoothing data with steep
      gradients it is possible for predicted values to be negative.
      `force.positive = TRUE` ensures that predictions remain positive.
      This is useful for several reasons. First, with lots of missing
      data more interpolation is needed and this can result in artefacts
      because the predictions are too far from the original data.
      Second, if it is known beforehand that the data are all positive,
      then this option carries that assumption through to the
      prediction. The only likely time where setting
      `force.positive = FALSE` would be if background concentrations
      were first subtracted resulting in data that is legitimately
      negative. For the vast majority of situations it is expected that
      the user will not need to alter the default option.

  `k`

  :   The smoothing value supplied to `gam` for the temporal and wind
      direction components, respectively. In some cases e.g. a trend
      plot with less than 1-year of data the smoothing with the default
      values may become too noisy and affected more by outliers.
      Choosing a lower value of `k` (say 10) may help produce a better
      plot.

  `normalise`

  :   If `TRUE` concentrations are normalised by dividing by their mean
      value. This is done *after* fitting the smooth surface. This
      option is particularly useful if one is interested in the patterns
      of concentrations for several pollutants on different scales e.g.
      NOx and CO. Often useful if more than one `pollutant` is chosen.

  `key.header`

  :   Adds additional text/labels to the scale key. For example, passing
      the options `key.header = "header", key.footer = "footer1"` adds
      addition text above and below the scale key. These arguments are
      passed to `drawOpenKey` via `quickText`, applying the `auto.text`
      argument, to handle formatting.

  `key.footer`

  :   see `key.footer`.

  `key.position`

  :   Location where the scale key is to plotted. Allowed arguments
      currently include `"top"`, `"right"`, `"bottom"` and `"left"`.

  `auto.text`

  :   Either `TRUE` (default) or `FALSE`. If `TRUE` titles and axis
      labels will automatically try and format pollutant names and units
      properly e.g. by subscripting the \`2' in NO2.

- control:

  **Deprecated.** Please use `type`.

## Value

Either:

- *Dynamic:* A leaflet object

- *Static:* A `ggplot2` object using
  [`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  coordinates with a `ggspatial` basemap

## Parallel processing with mirai

Creating a directional analysis map can take a lot of time; each polar
marker needs to be plot individually, and many of these require some
expensive computations. `openairmaps` supports parallel processing with
`{mirai}` to speed these computations up. Users may create workers by
running
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html) in
their R session.

    mirai::daemons(4)
    polarMap(polar_data, "no2")

Typically, spawning one fewer daemons than your number of available
cores is a useful rule of thumb. Parallel processing will be most useful
for the most computationally intensive plotting functions - i.e.,
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
and `annulusMap()`.

## Customisation of static maps using ggplot2

As all static plots functions are `ggplot2` figures, further
customisation is possible using functions such as
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html),
[`ggplot2::guides()`](https://ggplot2.tidyverse.org/reference/guides.html)
and
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html).

Subscripting pollutants (e.g., the "x" in "NOx") is achieved using the
[ggtext](https://wilkelab.org/ggtext/reference/ggtext.html) package.
Therefore if you choose to override the plot theme, it is recommended to
use `[ggplot2::theme()]` and `[ggtext::element_markdown()]` to define
the `strip.text` parameter.

Legends can be removed using `ggplot2::theme(legend.position = "none")`,
or further customised using
[`ggplot2::guides()`](https://ggplot2.tidyverse.org/reference/guides.html)
and either `color = ggplot2::guide_colourbar()` for continuous legends
or `color = ggplot2::guide_legend()` for discrete legends.

The extent of a map can be adjusted using the `xlim` and `ylim`
arguments of
[`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

    polarMap(polar_data, "no2", static = TRUE) +
        ggplot2::coord_sf(
            xlim = c(-0.3, 0.2),
            ylim = c(51.2, 51.8)
        )

## See also

[`openair::polarAnnulus()`](https://openair-project.github.io/openair/reference/polarAnnulus.html)

Other directional analysis maps:
[`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md),
[`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md),
[`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md),
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md),
[`pollroseMap()`](https://openair-project.github.io/openairmaps/reference/pollroseMap.md),
[`windroseMap()`](https://openair-project.github.io/openairmaps/reference/windroseMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
annulusMap(polar_data,
  pollutant = "nox",
  period = "hour",
  provider = "CartoDB.Voyager"
)
} # }
```
