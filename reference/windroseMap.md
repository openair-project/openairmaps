# Wind roses on dynamic and static maps

The `windroseMap()` function creates a map using wind roses as markers.
Multiple layers of markers can be created using the `type` argument. By
default, these maps are dynamic and can be panned, zoomed, and otherwise
interacted with. Using the `static` argument allows for static images to
be produced instead.

## Usage

``` r
windroseMap(
  data,
  ws.int = 2,
  breaks = 4,
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

  *Input data table with wind and geo-spatial information.*

  **required** \| *scope:* dynamic & static

  A data frame. The data frame must contain the data to plot the
  directional analysis marker, which includes wind speed (`ws`) and wind
  direction (`wd`). In addition, `data` must include a decimal latitude
  and longitude (or X/Y coordinate used in conjunction with `crs`).

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

  - *Static*: One of the options listed in
    [`rosm::osm.types()`](https://rdrr.io/pkg/rosm/man/deprecated.html)
    (for example, `"osm"`, `"cartodark"`, `"cartolight"`, etc.).

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
  [`openair::windRose`](https://openair-project.github.io/openair/reference/windRose.html)

  `ws`

  :   Name of the column representing wind speed.

  `wd`

  :   Name of the column representing wind direction.

  `ws2,wd2`

  :   The user can supply a second set of wind speed and wind direction
      values with which the first can be compared. See
      [`pollutionRose()`](https://openair-project.github.io/openair/reference/pollutionRose.html)
      for more details.

  `angle`

  :   Default angle of “spokes” is 30. Other potentially useful angles
      are 45 and 10. Note that the width of the wind speed interval may
      need adjusting using `width`.

  `calm.thresh`

  :   By default, conditions are considered to be calm when the wind
      speed is zero. The user can set a different threshold for calms be
      setting `calm.thresh` to a higher value. For example,
      `calm.thresh = 0.5` will identify wind speeds **below** 0.5 as
      calm.

  `bias.corr`

  :   When `angle` does not divide exactly into 360 a bias is introduced
      in the frequencies when the wind direction is already supplied
      rounded to the nearest 10 degrees, as is often the case. For
      example, if `angle = 22.5`, N, E, S, W will include 3 wind sectors
      and all other angles will be two. A bias correction can made to
      correct for this problem. A simple method according to
      Applequist (2012) is used to adjust the frequencies.

  `grid.line`

  :   Grid line interval to use. If `NULL`, as in default, this is
      assigned based on the available data range. However, it can also
      be forced to a specific value, e.g. `grid.line = 10`. `grid.line`
      can also be a list to control the interval, line type and colour.
      For example
      `grid.line = list(value = 10, lty = 5, col = "purple")`.

  `width`

  :   For `paddle = TRUE`, the adjustment factor for width of wind speed
      intervals. For example, `width = 1.5` will make the paddle width
      1.5 times wider.

  `seg`

  :   When `paddle = TRUE`, `seg` determines with width of the segments.
      For example, `seg = 0.5` will produce segments 0.5 \* `angle`.

  `auto.text`

  :   Either `TRUE` (default) or `FALSE`. If `TRUE` titles and axis
      labels will automatically try and format pollutant names and units
      properly, e.g., by subscripting the ‘2’ in NO2.

  `offset`

  :   The size of the 'hole' in the middle of the plot, expressed as a
      percentage of the polar axis scale, default 10.

  `normalise`

  :   If `TRUE` each wind direction segment is normalised to equal one.
      This is useful for showing how the concentrations (or other
      parameters) contribute to each wind sector when the proportion of
      time the wind is from that direction is low. A line showing the
      probability that the wind directions is from a particular wind
      sector is also shown.

  `max.freq`

  :   Controls the scaling used by setting the maximum value for the
      radial limits. This is useful to ensure several plots use the same
      radial limits.

  `paddle`

  :   Either `TRUE` or `FALSE`. If `TRUE` plots rose using 'paddle'
      style spokes. If `FALSE` plots rose using 'wedge' style spokes.

  `key.header`

  :   Adds additional text/labels above the scale key. For example,
      passing `windRose(mydata, key.header = "ws")` adds the addition
      text as a scale header. Note: This argument is passed to
      [`drawOpenKey()`](https://openair-project.github.io/openair/reference/drawOpenKey.html)
      via
      [`quickText()`](https://openair-project.github.io/openair/reference/quickText.html),
      applying the auto.text argument, to handle formatting.

  `key.footer`

  :   Adds additional text/labels below the scale key. See `key.header`
      for further information.

  `key.position`

  :   Location where the scale key is to plotted. Allowed arguments
      currently include “top”, “right”, “bottom” and “left”.

  `dig.lab`

  :   The number of significant figures at which scientific number
      formatting is used in break point and key labelling. Default 5.

  `include.lowest`

  :   Logical. If `FALSE` (the default), the first interval will be left
      exclusive and right inclusive. If `TRUE`, the first interval will
      be left and right inclusive. Passed to the `include.lowest`
      argument of [`cut()`](https://rdrr.io/r/base/cut.html).

  `statistic`

  :   The `statistic` to be applied to each data bin in the plot.
      Options currently include “prop.count”, “prop.mean” and
      “abs.count”. The default “prop.count” sizes bins according to the
      proportion of the frequency of measurements. Similarly,
      “prop.mean” sizes bins according to their relative contribution to
      the mean. “abs.count” provides the absolute count of measurements
      in each bin.

  `pollutant`

  :   Alternative data series to be sampled instead of wind speed. The
      [`windRose()`](https://openair-project.github.io/openair/reference/windRose.html)
      default NULL is equivalent to `pollutant = "ws"`. Use in
      [`pollutionRose()`](https://openair-project.github.io/openair/reference/pollutionRose.html).

  `angle.scale`

  :   The scale is by default shown at a 315 degree angle. Sometimes the
      placement of the scale may interfere with an interesting feature.
      The user can therefore set `angle.scale` to another value (between
      0 and 360 degrees) to mitigate such problems. For example
      `angle.scale = 45` will draw the scale heading in a NE direction.

  `border`

  :   Border colour for shaded areas. Default is no border.

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
and
[`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md).

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

[`openair::windRose()`](https://openair-project.github.io/openair/reference/windRose.html)

Other directional analysis maps:
[`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md),
[`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md),
[`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md),
[`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md),
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md),
[`pollroseMap()`](https://openair-project.github.io/openairmaps/reference/pollroseMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
windroseMap(polar_data,
  provider = "CartoDB.Voyager"
)
} # }
```
