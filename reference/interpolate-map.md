# Spatially interpolated dynamic and static maps

**\[experimental\]**

These functions create interpolated surfaces out of data at individual
monitoring sites. This can be useful to 'fill in the gaps' to estimate
pollution concentrations where no monitoring is occurring, or better
identify geographical patterns in pollution data. `krigingMap()` creates
a smooth spatially interpolated surface using either inverse distance
weighting or point kriging. `voronoiMap()` creates a surface of 'closest
observation' polygons. The kriging formula is currently always
`pollutant ~ 1`; `krigingMap()` does not currently support more complex
models.

## Usage

``` r
krigingMap(
  data,
  pollutant = NULL,
  statistic = "mean",
  percentile = 95,
  newdata = NULL,
  method = c("idw", "kriging"),
  breaks = NULL,
  labels = NULL,
  limits = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 0.8,
  show.markers = TRUE,
  marker.border = "white",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  static = FALSE,
  vgm = gstat::vgm(psill = 1, model = "Exp", range = 50000, nugget = 1),
  args.idw = list(),
  args.variogram = list(),
  args.fit.variogram = list(),
  args.krige = list()
)

voronoiMap(
  data,
  pollutant = NULL,
  statistic = "mean",
  percentile = 95,
  newdata = NULL,
  breaks = NULL,
  labels = NULL,
  limits = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  provider = "OpenStreetMap",
  cols = "turbo",
  alpha = 0.8,
  show.markers = TRUE,
  marker.border = "white",
  voronoi.border = "white",
  legend = TRUE,
  legend.position = NULL,
  legend.title = NULL,
  legend.title.autotext = TRUE,
  static = FALSE,
  args.voronoi = list()
)
```

## Arguments

- data:

  *Input data table with pollutant and geo-spatial information.*

  **required** \| *scope:* dynamic & static

  A data frame. The data frame must contain at least one numeric column
  to interpolate, plus a decimal latitude and longitude (or X/Y
  coordinate used in conjunction with `crs`).

- pollutant:

  *Pollutant name.*

  **required** \| *scope:* dynamic & static

  The column name of the pollutant to plot. Multiple `pollutants` are
  prohibited by this function.

- statistic:

  *Statistic for aggregating pollutant data.*

  *default:* `"mean"` \| *scope:* dynamic & static

  Pollutant data will be aggregated by latitude & longitude; `statistic`
  controls how this is achieved. Possible statistics include:

  - `"mean"`: the arithmetic mean (using
    [`mean()`](https://rdrr.io/r/base/mean.html))

  - `"median"`: the median (middle) value (using
    [`stats::median()`](https://rdrr.io/r/stats/median.html))

  - `"max"`: the maximum value (using
    [`max()`](https://rdrr.io/r/base/Extremes.html))

  - `"min"`: the maximum value (using
    [`min()`](https://rdrr.io/r/base/Extremes.html))

  - `"sd"`: the standard deviation (using
    [`stats::sd()`](https://rdrr.io/r/stats/sd.html))

  - `"percentile"`: a percentile value, defined using the `percentile`
    argument (using
    [`stats::quantile()`](https://rdrr.io/r/stats/quantile.html))

- percentile:

  *The percentile when \`statistic = "percentile"*

  *default:* `95` \| *scope:* dynamic & static

  The percentile level used when `statistic = "percentile"`. The default
  is `95`, representing 95%. Should be between `0` and `100`.

- newdata:

  *A spatial dataset of prediction locations.*

  *default:* `NULL` \| *scope:* dynamic & static

  By default, a bounding box of all latitudes and longitudes are used
  for prediction, but this is often not useful or aesthetically
  pleasing. `newdata` should be a spatial data frame (constructed with
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html)).
  This may be a country or authority boundary relevant to the `data`
  input.

- method:

  *Spatial interpolation method.*

  *default:* `"idw"` \| *scope:* dynamic & static

  The spatial interpolation method to use for `krigingMap()`. `"idw"`
  uses inverse distance weighting (IDW) which is simpler and faster.
  `"kriging"` uses full point kriging which is typically more accurate,
  but is also more complex and computationally intensive.

- labels, breaks:

  *Discretise the map color scale.*

  *default:* `NULL` \| *scope:* dynamic & static

  By default, a continuous colour scale is used. If `breaks` are
  provided, the colour scale will be discretised using
  [`cut()`](https://rdrr.io/r/base/cut.html). `labels` can also be
  provided to customise how each factor level is labelled.

- limits:

  *Specifier for the plot colour scale bounds.*

  *default:* `NULL` \| *scope:* dynamic & static

  A numeric vector in the form `c(lower, upper)` used to define the
  colour scale. For example, `limits = c(0, 100)` would force the plot
  limits to span 0-100. If `NULL`, appropriate limits will be selected
  based on the range in `data[[pollutant]]`.

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

- cols:

  *Colours to use for plotting.*

  *default:* `"turbo"` \| *scope:* dynamic & static

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).
  The default, `"turbo"`, is a rainbow palette with relatively
  perceptually uniform colours.

- alpha:

  *Transparency value for interpolated surface.*

  *default:* `1` \| *scope:* dynamic & static

  A value between 0 (fully transparent) and 1 (fully opaque).

- show.markers:

  *Show original monitoring site markers?*

  *default:* `TRUE` \| *scope:* dynamic & static

  When `TRUE`, the coordinates in the input `data` will be shown as
  coloured markers.

- marker.border, voronoi.border:

  *Border colour to use for markers and voronoi tiles.*

  *default:* `"white"` \| *scope:* dynamic & static

  Any valid HTML colour (e.g., a hex code). Use `NA` for no border.

- legend:

  *Draw a legend?*

  *default:* `TRUE` \| *scope:* dynamic & static

  When `TRUE`, a legend will appear on the map identifying the colour
  scale.

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

- static:

  *Produce a static map?*

  *default:* `FALSE`

  This controls whether a *dynamic* or *static* map is produced. The
  former is the default and is broadly more useful, but the latter may
  be preferable for DOCX or PDF outputs (e.g., academic papers).

- vgm:

  *A variogram model*

  *default:*
  `gstat::vgm(psill = 1, model = "Exp", range = 50000, nugget = 1)` \|
  *scope:* dynamic & static

  The variogram model to use when `method = "kriging"`. Must be the
  output of
  [`gstat::vgm()`](https://r-spatial.github.io/gstat/reference/vgm.html).

- args.idw, args.variogram, args.fit.variogram, args.krige:

  *Extra arguments to pass to spatial interpolation functions for
  `krigingMap()`.*

  *scope:* dynamic & static

  Extra arguments passed to
  [`gstat::idw()`](https://r-spatial.github.io/gstat/reference/krige.html),
  [`gstat::vgm()`](https://r-spatial.github.io/gstat/reference/vgm.html),
  [`gstat::fit.variogram()`](https://r-spatial.github.io/gstat/reference/fit.variogram.html),
  and
  [`gstat::krige()`](https://r-spatial.github.io/gstat/reference/krige.html).

- args.voronoi:

  *Extra arguments to pass to spatial interpolation functions for
  `voronoiMap()`.*

  *scope:* dynamic & static

  Extra arguments passed to
  [`terra::voronoi()`](https://rspatial.github.io/terra/reference/voronoi.html),
  with the exception of `x` which is dealt with by `voronoiMap()`.

## Value

Either:

- *Dynamic:* A leaflet object

- *Static:* A `ggplot2` object using
  [`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  coordinates with a `ggspatial` basemap

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

## Examples

``` r
if (FALSE) { # \dontrun{
# import ozone DAQI
daqi <-
  openair::importUKAQ(
    pollutant = "o3",
    year = 2020,
    source = "aurn",
    data_type = "daqi",
    meta = TRUE
  )

# get a UK shapefile
uk <- rnaturalearth::ne_countries(scale = 10, country = "united kingdom")

# create spatially interpolated map
voronoiMap(
  daqi,
  pollutant = "poll_index",
  newdata = uk,
  statistic = "max",
  breaks = seq(0.5, 10.5, 1),
  labels = as.character(1:10),
  legend.title = "Max O3 DAQI",
  cols = "daqi"
)

krigingMap(
  daqi,
  pollutant = "poll_index",
  newdata = uk,
  statistic = "max",
  legend.title = "Max O3 DAQI",
  cols = openair::openColours("daqi", n = 10),
  limits = c(1, 10)
)
} # }
```
