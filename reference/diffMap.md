# Bivariate polar 'difference' plots on dynamic and static maps

The `diffMap()` function creates a map using bivariate polar plots as
markers. Any number of pollutants can be specified using the `pollutant`
argument, and multiple layers of markers can be created using `type`. By
default, these maps are dynamic and can be panned, zoomed, and otherwise
interacted with. Using the `static` argument allows for static images to
be produced instead.

## Usage

``` r
diffMap(
  before,
  after,
  pollutant = NULL,
  x = "ws",
  limits = "free",
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = rev(openair::openColours("RdBu", 10)),
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

- before, after:

  Data frames representing the "before" and "after" cases. See
  [`polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  for details of different input requirements.

- pollutant:

  Mandatory. A pollutant name corresponding to a variable in a data
  frame should be supplied e.g. `pollutant = "nox"`. There can also be
  more than one pollutant specified e.g. `pollutant = c("nox", "no2")`.
  The main use of using two or more pollutants is for model evaluation
  where two species would be expected to have similar concentrations.
  This saves the user stacking the data and it is possible to work with
  columns of data directly. A typical use would be
  `pollutant = c("obs", "mod")` to compare two columns “obs” (the
  observations) and “mod” (modelled values). When pair-wise statistics
  such as Pearson correlation and regression techniques are to be
  plotted, `pollutant` takes two elements too. For example,
  `pollutant = c("bc", "pm25")` where `"bc"` is a function of `"pm25"`.

- x:

  Name of variable to plot against wind direction in polar coordinates,
  the default is wind speed, “ws”.

- limits:

  *Limits for the plot colour scale.*

  *default:* `"free"` \| *scope:* dynamic & static

  One of:

  - `"free"` (the default) which allows all of the markers to use
    different colour scales.

  - A numeric vector in the form `c(lower, upper)` used to define the
    colour scale. For example, `limits = c(-10, 10)` would force the
    plot limits to span -10 to 10. It is recommended to use a
    symmetrical limit scale (along with a "diverging" colour palette)
    for effective visualisation.

  Note that the `"fixed"` option is not supported in `diffMap()`.

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

  `type` determines how the data are split i.e. conditioned, and then
  plotted. The default is will produce a single plot using the entire
  data. Type can be one of the built-in types as detailed in `cutData`
  e.g. “season”, “year”, “weekday” and so on. For example,
  `type = "season"` will produce four plots — one for each season.

  It is also possible to choose `type` as another variable in the data
  frame. If that variable is numeric, then the data will be split into
  four quantiles (if possible) and labelled accordingly. If type is an
  existing character or factor variable, then those categories/levels
  will be used directly. This offers great flexibility for understanding
  the variation of different variables and how they depend on one
  another.

  Type can be up length two e.g. `type = c("season", "weekday")` will
  produce a 2x2 plot split by season and day of the week. Note, when two
  types are provided the first forms the columns and the second the
  rows.

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

  *default:* `rev(openair::openColours("RdBu", 10))` \| *scope:* dynamic
  & static

  The colours used for plotting, passed to
  [`openair::openColours()`](https://openair-project.github.io/openair/reference/openColours.html).
  It is recommended to use a "diverging" colour palette (along with a
  symmetrical `limit` scale) for effective visualisation.

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
  [`openair::polarPlot`](https://openair-project.github.io/openair/reference/polarPlot.html)

  `wd`

  :   Name of wind direction field.

  `statistic`

  :   The statistic that should be applied to each wind speed/direction
      bin. Because of the smoothing involved, the colour scale for some
      of these statistics is only to provide an indication of overall
      pattern and should not be interpreted in concentration units e.g.
      for `statistic = "weighted.mean"` where the bin mean is multiplied
      by the bin frequency and divided by the total frequency. In many
      cases using `polarFreq` will be better. Setting
      `statistic = "weighted.mean"` can be useful because it provides an
      indication of the concentration \* frequency of occurrence and
      will highlight the wind speed/direction conditions that dominate
      the overall mean.Can be:

      - “mean” (default), “median”, “max” (maximum), “frequency”.
        “stdev” (standard deviation), “weighted.mean”.

      - `statistic = "nwr"` Implements the Non-parametric Wind
        Regression approach of Henry et al. (2009) that uses kernel
        smoothers. The `openair` implementation is not identical because
        Gaussian kernels are used for both wind direction and speed. The
        smoothing is controlled by `ws_spread` and `wd_spread`.

      - `statistic = "cpf"` the conditional probability function (CPF)
        is plotted and a single (usually high) percentile level is
        supplied. The CPF is defined as CPF = my/ny, where my is the
        number of samples in the y bin (by default a wind direction,
        wind speed interval) with mixing ratios greater than the
        *overall* percentile concentration, and ny is the total number
        of samples in the same wind sector (see Ashbaugh et al., 1985).
        Note that percentile intervals can also be considered; see
        `percentile` for details.

      - When `statistic = "r"` or `statistic = "Pearson"`, the Pearson
        correlation coefficient is calculated for *two* pollutants. The
        calculation involves a weighted Pearson correlation coefficient,
        which is weighted by Gaussian kernels for wind direction an the
        radial variable (by default wind speed). More weight is assigned
        to values close to a wind speed-direction interval. Kernel
        weighting is used to ensure that all data are used rather than
        relying on the potentially small number of values in a wind
        speed-direction interval.

      - When `statistic = "Spearman"`, the Spearman correlation
        coefficient is calculated for *two* pollutants. The calculation
        involves a weighted Spearman correlation coefficient, which is
        weighted by Gaussian kernels for wind direction an the radial
        variable (by default wind speed). More weight is assigned to
        values close to a wind speed-direction interval. Kernel
        weighting is used to ensure that all data are used rather than
        relying on the potentially small number of values in a wind
        speed-direction interval.

      - `"robust_slope"` is another option for pair-wise statistics and
        `"quantile.slope"`, which uses quantile regression to estimate
        the slope for a particular quantile level (see also `tau` for
        setting the quantile level).

      - `"york_slope"` is another option for pair-wise statistics which
        uses the *York regression method* to estimate the slope. In this
        method the uncertainties in `x` and `y` are used in the
        determination of the slope. The uncertainties are provided by
        `x_error` and `y_error` — see below.

  `exclude.missing`

  :   Setting this option to `TRUE` (the default) removes points from
      the plot that are too far from the original data. The smoothing
      routines will produce predictions at points where no data exist
      i.e. they predict. By removing the points too far from the
      original data produces a plot where it is clear where the original
      data lie. If set to `FALSE` missing data will be interpolated.

  `uncertainty`

  :   Should the uncertainty in the calculated surface be shown? If
      `TRUE` three plots are produced on the same scale showing the
      predicted surface together with the estimated lower and upper
      uncertainties at the 95% confidence interval. Calculating the
      uncertainties is useful to understand whether features are real or
      not. For example, at high wind speeds where there are few data
      there is greater uncertainty over the predicted values. The
      uncertainties are calculated using the GAM and weighting is done
      by the frequency of measurements in each wind speed-direction bin.
      Note that if uncertainties are calculated then the type is set to
      "default".

  `percentile`

  :   If `statistic = "percentile"` then `percentile` is used, expressed
      from 0 to 100. Note that the percentile value is calculated in the
      wind speed, wind direction ‘bins’. For this reason it can also be
      useful to set `min.bin` to ensure there are a sufficient number of
      points available to estimate a percentile. See `quantile` for more
      details of how percentiles are calculated.

      `percentile` is also used for the Conditional Probability Function
      (CPF) plots. `percentile` can be of length two, in which case the
      percentile *interval* is considered for use with CPF. For example,
      `percentile = c(90, 100)` will plot the CPF for concentrations
      between the 90 and 100th percentiles. Percentile intervals can be
      useful for identifying specific sources. In addition, `percentile`
      can also be of length 3. The third value is the ‘trim’ value to be
      applied. When calculating percentile intervals many can cover very
      low values where there is no useful information. The trim value
      ensures that values greater than or equal to the trim \* mean
      value are considered *before* the percentile intervals are
      calculated. The effect is to extract more detail from many source
      signatures. See the manual for examples. Finally, if the trim
      value is less than zero the percentile range is interpreted as
      absolute concentration values and subsetting is carried out
      directly.

  `weights`

  :   At the edges of the plot there may only be a few data points in
      each wind speed-direction interval, which could in some situations
      distort the plot if the concentrations are high. `weights` applies
      a weighting to reduce their influence. For example and by default
      if only a single data point exists then the weighting factor is
      0.25 and for two points 0.5. To not apply any weighting and use
      the data as is, use `weights = c(1, 1, 1)`.

      An alternative to down-weighting these points they can be removed
      altogether using `min.bin`.

  `min.bin`

  :   The minimum number of points allowed in a wind speed/wind
      direction bin. The default is 1. A value of two requires at least
      2 valid records in each bin an so on; bins with less than 2 valid
      records are set to NA. Care should be taken when using a value \>
      1 because of the risk of removing real data points. It is
      recommended to consider your data with care. Also, the `polarFreq`
      function can be of use in such circumstances.

  `mis.col`

  :   When `min.bin` is \> 1 it can be useful to show where data are
      removed on the plots. This is done by shading the missing data in
      `mis.col`. To not highlight missing data when `min.bin` \> 1
      choose `mis.col = "transparent"`.

  `upper`

  :   This sets the upper limit wind speed to be used. Often there are
      only a relatively few data points at very high wind speeds and
      plotting all of them can reduce the useful information in the
      plot.

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

  :   This is the smoothing parameter used by the `gam` function in
      package `mgcv`. Typically, value of around 100 (the default) seems
      to be suitable and will resolve important features in the plot.
      The most appropriate choice of `k` is problem-dependent; but
      extensive testing of polar plots for many different problems
      suggests a value of `k` of about 100 is suitable. Setting `k` to
      higher values will not tend to affect the surface predictions by
      much but will add to the computation time. Lower values of `k`
      will increase smoothing. Sometimes with few data to plot
      `polarPlot` will fail. Under these circumstances it can be worth
      lowering the value of `k`.

  `normalise`

  :   If `TRUE` concentrations are normalised by dividing by their mean
      value. This is done *after* fitting the smooth surface. This
      option is particularly useful if one is interested in the patterns
      of concentrations for several pollutants on different scales e.g.
      NOx and CO. Often useful if more than one `pollutant` is chosen.

  `auto.text`

  :   Either `TRUE` (default) or `FALSE`. If `TRUE` titles and axis
      labels will automatically try and format pollutant names and units
      properly e.g. by subscripting the \`2' in NO2.

  `ws_spread`

  :   The value of sigma used for Gaussian kernel weighting of wind
      speed when `statistic = "nwr"` or when correlation and regression
      statistics are used such as *r*. Default is `0.5`.

  `wd_spread`

  :   The value of sigma used for Gaussian kernel weighting of wind
      direction when `statistic = "nwr"` or when correlation and
      regression statistics are used such as *r*. Default is `4`.

  `x_error`

  :   The `x` error / uncertainty used when `statistic = "york_slope"`.

  `y_error`

  :   The `y` error / uncertainty used when `statistic = "york_slope"`.

  `kernel`

  :   Type of kernel used for the weighting procedure for when
      correlation or regression techniques are used. Only `"gaussian"`
      is supported but this may be enhanced in the future.

  `formula.label`

  :   When pair-wise statistics such as regression slopes are calculated
      and plotted, should a formula label be displayed? `formula.label`
      will also determine whether concentration information is printed
      when `statistic = "cpf"`.

  `tau`

  :   The quantile to be estimated when `statistic` is set to
      `"quantile.slope"`. Default is `0.5` which is equal to the median
      and will be ignored if `"quantile.slope"` is not used.

  `plot`

  :   Should a plot be produced? `FALSE` can be useful when analysing
      data to extract plot components and plotting them in other ways.

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

[`openair::polarDiff()`](https://openair-project.github.io/openair/reference/polarDiff.html)

Other directional analysis maps:
[`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md),
[`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md),
[`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md),
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md),
[`pollroseMap()`](https://openair-project.github.io/openairmaps/reference/pollroseMap.md),
[`windroseMap()`](https://openair-project.github.io/openairmaps/reference/windroseMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# NB: "after" is some dummy data to demonstrate functionality
diffMap(
  before = polar_data,
  after = dplyr::mutate(polar_data, nox = jitter(nox, factor = 5)),
  pollutant = "nox"
)
} # }
```
