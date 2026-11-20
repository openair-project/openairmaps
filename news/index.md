# Changelog

## openairmaps (development version)

### Breaking changes

- Several deprecated functions and arguments have been removed:

  - `trajMapStatic()` and `trajLevelMapStatic()`. Use
    [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
    and
    [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html)
    instead.

  - `searchNetwork()`, which is superseded by
    [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
    (see below).

  - The `control` argument of the
    [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
    family and
    [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md),
    and the `facet` argument from `polarMapStatic()`. Use `type`
    instead; the
    [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
    family now errors with a pointer to `type` if either is used.
    `control` in
    [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
    is unaffected.

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now take `latitude` before `longitude`. Both default to `NULL` and are
  guessed from `data`, in line with the rest of the package.

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  now uses `cols = "turbo"` by default, in line with the rest of the
  package. It also now errors if `colour` is neither a column of `data`
  nor a valid colour (e.g., a misspelled column name), rather than
  passing it on to [leaflet](https://rstudio.github.io/leaflet/).

- The default `vgm` in
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  now has a `range` of 50 rather than 50,000. As the data are in
  latitude and longitude, [gstat](https://github.com/r-spatial/gstat/)
  measures this in kilometres, so the previous default was far larger
  than intended.

- “Layer control” menus now list `type` levels in the order of their
  factor levels (e.g., “Monday” before “Tuesday”), and multiple
  pollutants in the order they were given, rather than the order they
  first appear in the data.

- [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  now only applies
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)
  to its labels, not its values, as these are the user’s data (e.g., a
  value of “No” was previously shown as “NO”).

- `polar_data` now includes the site code, and its columns have been
  reordered to better match
  [`openair::importUKAQ()`](https://openair-project.github.io/openair/reference/importUKAQ.html).

### New features

#### New functions

- [`pointMap()`](https://openair-project.github.io/openairmaps/reference/pointMap.md)
  summarises pollutant data at each site (e.g., the mean concentration)
  and shows it as coloured circles on a dynamic or static map. It shares
  its arguments with
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md),
  but draws no interpolated surface.

- [`addTrajLevel()`](https://openair-project.github.io/openairmaps/reference/addTrajLevel.md)
  adds gridded trajectory statistics (from
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html))
  to any `leaflet` map, much like
  [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  does for individual trajectories. It offers more control over groups
  and layer IDs than
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md),
  which now uses it internally.

- [`breakOpts()`](https://openair-project.github.io/openair/reference/breakOpts.html)
  and
  [`colourOpts()`](https://openair-project.github.io/openair/reference/colourOpts.html)
  are now re-exported from
  [openair](https://openair-project.github.io/openair/).

#### Directional analysis maps

- [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and
  [`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md)
  gain `breaks`, in line with
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  and
  [`openair::polarAnnulus()`](https://openair-project.github.io/openair/reference/polarAnnulus.html),
  to bin the colour scale into discrete intervals. This takes a numeric
  vector of breakpoints, a number of intervals, or
  [`openair::breakOpts()`](https://openair-project.github.io/openair/reference/breakOpts.html).
  A single set of breakpoints is calculated across *all* of the markers
  so they can share a legend. `breaks` overrides `limits`.

- Shared legends have been standardised, and now reflect the colour
  scale [openair](https://openair-project.github.io/openair/) actually
  used to draw the markers:

  - Discrete colour scales (e.g., from `breaks`) now get a legend of
    labelled colours, as long as all markers share the same intervals.

  - Labels and colours now exactly match those used by
    [openair](https://openair-project.github.io/openair/), and are the
    same in dynamic and static maps (e.g., `"0 to 50"` rather than
    `"0 – 50"`).

  - Continuous legends are no longer drawn for transformed colour scales
    (e.g., `trans = "log10"`), as they would be misleading. This
    includes
    [`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md)
    by default, as
    [`openair::polarFreq()`](https://openair-project.github.io/openair/reference/polarFreq.html)
    uses `trans = "sqrt"`; pass `limits` and `trans = FALSE` via `...`
    to get a shared continuous legend.

  - Dynamic legends now consistently use `alpha` for their opacity.

- [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  and
  [`addPolarDiffMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  gain `progress`, in line with the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family, so the progress bar can be turned off.

#### Site maps

- [`pointMap()`](https://openair-project.github.io/openairmaps/reference/pointMap.md),
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  gain `type`, in line with the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family. Each `type` level is summarised (and interpolated) separately
  on a shared colour scale. Levels become layers of a dynamic map
  (switched between using a “layer control” menu, customised using the
  `control.*` arguments) or panels of a static map (arranged using
  `static.nrow`). Other arguments can be passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html)
  using `...`.

- [`pointMap()`](https://openair-project.github.io/openairmaps/reference/pointMap.md),
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  gain `popup` and `label`, which work like those in
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).
  If either includes the `pollutant`, the site `statistic` is shown and
  labelled as such (e.g., “NO₂ (max)”). Other numeric columns are
  averaged at each site.

#### Trajectory maps

- [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  gains `markerColor`, so the points along a trajectory can be coloured
  independently of its line (e.g., by a pollutant). It is also much
  faster when `layerId` is used, with unchanged layer IDs.

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now passes `...` to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html)
  (e.g., `type = "season", hemisphere = "southern"`), in line with
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md).
  Its `pollutant` argument also now defaults to `NULL`.

- Trajectory popups have been restyled to match those in
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md).
  Path popups always show the time of the arrival and trajectory dates,
  and
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  shows the `colour` variable (e.g., a pollutant) in its own row.
  Gridded popups lead with the value and statistic, followed by the grid
  cell location, count and (if used) `type` level.

#### Other

- [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  popups have been restyled to match those in
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md),
  with each column shown as a grey label alongside its value. This also
  applies to the popups built automatically when several `popup` columns
  are given to a mapping function.
  [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  also gains `name`, which sets the name of the new column (`"popup"` by
  default), and now errors if this column already exists rather than
  returning `popup.x` and `popup.y`.

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  can now take any argument of
  [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
  via `...`, superseding `searchNetwork()`. It also no longer overrides
  the default `year`.

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md),
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md),
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  now accept any number of basemaps through `provider`, which can be
  named to label them in the layer control menu (e.g.,
  `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`),
  in line with
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md).

- The layer control menu now works the same way in all dynamic maps.
  Only the first basemap is shown initially, and a single basemap is no
  longer listed, as there is nothing to switch to.

- Static maps gain `api_key`, passed to
  [`ggspatial::annotation_map_tile()`](https://paleolimbot.github.io/ggspatial/reference/annotation_map_tile.html).

### Bug fixes

#### Directional analysis maps

- `freqMap(statistic = "frequency")` now shows the number of
  measurements in each bin. With recent versions of
  [openair](https://openair-project.github.io/openair/), it instead
  warned and showed the mean of an internal placeholder column, which
  also affected `breaks = "fixed"`.

- Markers that [openair](https://openair-project.github.io/openair/)
  can’t draw (e.g., due to too little data at a site) are now
  consistently skipped. Previously, dynamic maps showed a broken image
  in their place (and listed it in the layer control menu), and static
  maps errored. If no markers can be drawn at all, the error given by
  [openair](https://openair-project.github.io/openair/) is now passed
  on.

- `popup` and `label` are more robust:

  - A single numeric column (e.g., `popup = "no2"`) no longer errors.
    Numeric columns are now averaged at each marker and labelled as such
    (e.g., “NO₂ (mean)”), whether one or several `popup` columns are
    given.

  - [`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md)
    no longer errors when several `popup` columns are given.

  - The latitude and longitude columns, and columns called “popup” or
    “label”, can now be used. Previously, they errored (e.g.,
    `popup = c("site", "lat")`) or were overwritten (e.g.,
    `popup = "label"` showed “NA” in every popup). Internal columns also
    no longer overwrite columns called “dummy” (in
    [`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md))
    or “dummyvar” (in
    [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)).

- Shared scales now better match the markers:
  `polarMap(limits = "fixed")` uses the same `upper` as the markers,
  `percentileMap(intervals = "fixed")` uses `percentile` and `...`, and
  `freqMap(breaks = "fixed")` no longer errors when `trans` is passed
  via `...`.

- The colours in the dynamic
  [`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md)
  legend now match those of the markers.

- [`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md)
  no longer warns that “fixed” `intervals` only work with a single
  pollutant unless `intervals = "fixed"` was explicitly set. This
  warning (also given by
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md),
  [`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md)
  and
  [`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md))
  now names the relevant argument.

- [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  now drops rows where `pollutant` is missing, rather than where `no2`
  is missing, and so no longer errors if `data` has no `no2` column.

- [`windroseMap()`](https://openair-project.github.io/openairmaps/reference/windroseMap.md)
  now gives an informative error if `data` has no `ws` column.

#### Site maps

- [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  now give informative errors if `pollutant` is missing, can’t be found
  in `data` or has more than one value, or if `statistic` isn’t
  recognised.

- [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  no longer leave sites or parts of the surface uncoloured:

  - Values outside `limits` now take the colour of the nearest limit, as
    in [openair](https://openair-project.github.io/openair/).

  - When the data fall outside `breaks`, the outermost breaks are
    expanded to cover them (e.g., `breaks = c(50, 100, 150)` becomes
    `c(25, 100, 200)` for data ranging from 25 to 200). Values equal to
    the lowest break are also now included.

- `krigingMap(statistic = "sd")` and `voronoiMap(statistic = "sd")` now
  treat sites with a single measurement as missing, rather than using
  the measurement itself.

- Static
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  maps now respect `provider`, rather than always using OpenStreetMap.

#### Trajectory maps

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and
  [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  now support data with multiple receptors, as returned by
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).
  Previously, trajectories arriving at different receptors at the same
  time were joined into a single path.

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now respects `control.collapsed` and `control.position`. Note that
  this means its layer control is now expanded by default, in line with
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md).

- `trajLevelMap(statistic = "difference")` now uses the correct ordinal
  suffix for `percentile` (e.g., `"11th"` rather than `"11st"`, `"1st"`
  rather than `"1th"`, and `"92.5th"` rather than `"92.5nd"`).

- [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  popups now respect `lng` and `lat`. Previously, the latitude and
  longitude were blank unless the columns were called “lon” and “lat”.

#### Other

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md),
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md),
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md),
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  and
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  now validate `provider` in the same way as the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family, giving an informative error for unrecognised basemaps and
  accepting the same shorthand names (e.g., `"cartolight"`).

- Dynamic maps now error if more than one `legend.position` or
  `control.position` is given.
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  now checks `control.position` even when `control` isn’t used.

- Dynamic
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md),
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md),
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  legends now use `alpha` for their opacity.

- Fewer noisy messages:
  [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  no longer prints [gstat](https://github.com/r-spatial/gstat/)’s
  progress for every `type` level (turn it back on with, e.g.,
  `args.idw = list(debug.level = 1)`),
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  no longer warns that “attribute variables are assumed to be spatially
  constant”, and static
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family maps no longer warn that “st_point_on_surface may not give
  correct results”.

- [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  now shows columns in the order given in `columns`, summarises `Date`
  columns (using `fun.dttm`) and logical columns (using
  `fun.character`), and shows the latitude and longitude columns as-is.
  Previously, columns were ordered by type, `Date` and logical columns
  errored, and latitude/longitude columns either errored (if named) or
  were left out.

- [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)
  now correctly formats `"m/s2"`.

## openairmaps 0.10.1

CRAN release: 2026-05-20

### New features

- The entire
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family now defaults to `annotate = FALSE`, which removes many of the
  “captions” added automatically since
  [openair](https://openair-project.github.io/openair/) v.3.1.0. These
  can be restored by passing `annotate = TRUE` to `...`.

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  has gained `breaks` in line with
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html).

- `trajMapStatic()` and `trajLevelMapStatic()` now call
  `openair::trajMap()` and
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html),
  respectively. This is an advancement towards complete removal, which
  will happen in a future version of `openairmaps`.

## openairmaps 0.10.0

CRAN release: 2026-04-04

### Breaking Changes

- [openairmaps](https://openair-project.github.io/openairmaps/) now
  depends on a minimum R version of 4.1.0 and no longer exports the
  [magrittr](https://magrittr.tidyverse.org) pipe (`%>%`). Users are
  encouraged to use the base R pipe (`|>`) instead. In most cases, this
  is a drop-in replacement.

- [openairmaps](https://openair-project.github.io/openairmaps/) now
  requires a a minimum
  [openair](https://openair-project.github.io/openair/) version of
  3.0.0. Polar markers are therefore now produced using `ggplot2`. This
  has allowed the `theme` argument to be added to the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family, which allows for extensive customisation of polar markers.
  This has included the following changes:

  - `key` has been replaced with `key.position`, in line with
    deprecations in
    [openair](https://openair-project.github.io/openair/).

  - Polar markers will inherit any styling set using
    [`ggplot2::theme_set()`](https://ggplot2.tidyverse.org/reference/get_theme.html).
    This may be unfavourable, but can be partially overriden using the
    new `theme` argument.

- The `polarMapStatic()` family have been removed. The `trajMapStatic()`
  family are still exported but have been deprecated.

### New features

- The
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  gains the `theme` argument for customising the `ggplot2` theme of the
  markers.

- Added a new ‘spatial interpolation’ family of functions, which rely on
  the suggested [stars](https://r-spatial.github.io/stars/),
  [terra](https://rspatial.org/) and
  [gstat](https://github.com/r-spatial/gstat/) packages. These functions
  are most useful for dense air quality networks, and can be useful for
  identifying spatial patterns and hotspots of air pollution.

  - [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
    allows for smooth spatial interpolation, either using simple inverse
    distance weighting or full point kriging.

  - [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
    uses
    [`terra::voronoi`](https://rspatial.github.io/terra/reference/voronoi.html)
    to create a polygonal map of ‘closest observations’.

- Polar marker functions (both the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family and
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md))
  can now be run asynchronously if the user sets
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html).
  Internally, this uses
  [`purrr::in_parallel()`](https://purrr.tidyverse.org/reference/in_parallel.html).

- The progress bar shown when `progress = TRUE` now better reflects the
  actual time until function completion.

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  can now use `source = 'imperial'`, in line with updates to
  [openair](https://openair-project.github.io/openair/).

### Refactoring

This release includes several changes to make
[openairmaps](https://openair-project.github.io/openairmaps/) more
lightweight.

- [ggspatial](https://paleolimbot.github.io/ggspatial/),
  [prettymapr](https://github.com/paleolimbot/prettymapr) and
  [ggtext](https://wilkelab.org/ggtext/), the packages which support
  static mapping, have been moved to `Suggests` from `Imports`. This
  gives the package a smaller size for users who only use
  [openairmaps](https://openair-project.github.io/openairmaps/) for
  interactive mapping. On first trying to use a static mapping function,
  users will be prompted to install these packages.

- `{mgcv}` has been moved to `Suggests` as it is only used in one place
  (`trajLevelMap(smooth = TRUE)`)

- [`convertPostcode()`](https://openair-project.github.io/openairmaps/reference/convertPostcode.md)
  now uses [curl](https://jeroen.r-universe.dev/curl) over
  [httr](https://httr.r-lib.org/).

- Removed dependency on [forcats](https://forcats.tidyverse.org/).

- Removed suggested dependency on
  [worldmet](https://openair-project.github.io/worldmet/).

## openairmaps 0.9.1

CRAN release: 2024-11-19

### New features

- Pairwise statistics (e.g., `"robust_slope"`) are now supported by
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).
  ([\#72](https://github.com/openair-project/openairmaps/issues/72))

- The
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family has gained the `progress` argument, allowing users to switch
  the progress bar on and off.

- `trajMapStatic()` has gained the `size` and `linewidth` arguments,
  which directly map onto the arguments in
  [`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)
  and
  [`ggplot2::geom_path()`](https://ggplot2.tidyverse.org/reference/geom_path.html),
  respectively. These can either be a column of the data (like
  `colour`), or can be an absolute value (e.g., `2L`). Note that, by
  default, `linewidth` takes the value of `size`, but both can be set
  independently.

### Bug fixes

- Vectors greater than length 1 passed to `popup` in the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  argument will no longer error when `type = NULL`.

- `...` will successfully pass to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html)
  in the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  families of functions.

- The default
  [`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md)
  colour scale will no longer appear inverted compared to
  [`openair::polarDiff()`](https://openair-project.github.io/openair/reference/polarDiff.html).

- Fixed an issue in which
  [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)
  would incorrectly format non breaking spaces when doing, e.g.,
  `quickTextHTML("ug/m3")`.

- The order in which `trajMapStatic()` draws points and paths has been
  tweaked, which should ensure that markers are drawn on top of their
  respective path, rather than on top of all paths.

- [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  will now work correctly if no `type` is provided.

## openairmaps 0.9.0

CRAN release: 2024-05-19

### Breaking changes

- BREAKING: The `polarMapStatic()` family is now powered by
  [ggspatial](https://paleolimbot.github.io/ggspatial/) rather than
  [ggmap](https://github.com/dkahle/ggmap) as it does not require an API
  key. This means the `ggmap` argument has been removed and the
  `provider` argument has been added. Other benefits of this switch
  include a greater number of available base maps (see:
  [`rosm::osm.types()`](https://rdrr.io/pkg/rosm/man/deprecated.html))
  and the ability to simply change the extent of the map axes using
  [`ggplot2::coord_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  ([\#52](https://github.com/openair-project/openairmaps/issues/52))

- BREAKING: The `control` and `facet` arguments have been deprecated in
  favour of `type` in all functions. These arguments will eventually be
  removed, but as of this version of
  [openairmaps](https://openair-project.github.io/openairmaps/) users
  will be warned away from their use. This brings
  [openairmaps](https://openair-project.github.io/openairmaps/) in-line
  with the [openair](https://openair-project.github.io/openair/)
  package.

- BREAKING: The `names` and `cols` arguments of
  [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  have been coalesced into a single `columns` argument for less verbose
  function usage.

- BREAKING: The `collapse.control` argument has been renamed to
  `control.collapsed` and the `draw.legend` argument to `legend`. This
  is to allow these options to sit more nicely with their new argument
  family members - `legend.title`, `legend.title.autotext`,
  `legend.position`, and so on.

### New features

- The `polarMapStatic()` family of functions have been combined with the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family, with static maps available to be accessed using the `static`
  argument.
  ([\#59](https://github.com/openair-project/openairmaps/issues/59)) The
  `polarMapStatic()` family are therefore deprecated, and will later be
  removed from
  [openairmaps](https://openair-project.github.io/openairmaps/). The
  justification for this is as follows:

  - The combined functions allows for a more simple, consistent API for
    users (e.g., avoiding needing to switch between `facet` and
    `control`).

  - The use of the `static` argument allows for simple switching between
    dynamic and static maps. For example, a researcher may wish to use
    the dynamic maps for data exploration, but then switch to a static
    map for placement into a PDF report.

  - Recent developments have meant that the arguments and capability of
    these functions have started to align regardless (e.g., `provider`,
    `crs`).

  - Combining these functions has reduced repetition in the source code
    of [openairmaps](https://openair-project.github.io/openairmaps/),
    reducing the likelihood of oversights and bugs, and allowing for
    more rapid development.

- The `crs` argument has been added to the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and `polarMapStatic()` families and to `searchNetwork()`. This
  argument allows for users to specify that their data is using an
  alternative coordinate system to the standard longitude/latitude
  (e.g., the British National Grid CRS). Alternate CRS will be
  re-projected to longitude/latitude for plotting as this is expected by
  [leaflet](https://rstudio.github.io/leaflet/) /
  [ggspatial](https://paleolimbot.github.io/ggspatial/).
  ([\#56](https://github.com/openair-project/openairmaps/issues/56))

- Users now have greater control over the positions of legends and layer
  control menus, and the titles of legends, throughout
  [openairmaps](https://openair-project.github.io/openairmaps/)
  functions, including the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family,
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  family, and
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md).

- Popups for the dynamic
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family will now be near the top of the plot rather than the centre.
  This will obscure less of the plot itself while the marker is visible.
  ([\#55](https://github.com/openair-project/openairmaps/issues/55))

- [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)’s
  lookup table has gained new pollutants and units, and ignores the
  input case of `text` more consistently.

- Two examples of the use of
  [openairmaps](https://openair-project.github.io/openairmaps/) with
  [shiny](https://shiny.posit.co/) have been added to the package. Run
  `shiny::runExample(package = "openairmaps")` to view these.
  ([\#60](https://github.com/openair-project/openairmaps/issues/60))

### Bug fixes

- Legends drawn by the `polarMapStatic()` function should now render
  using more recent versions of
  [ggplot2](https://ggplot2.tidyverse.org).

- The
  [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  `layerId` argument is now implemented in a sensible way to ensure each
  geometry has a unique `layerId` and can therefore be interacted with
  in a [shiny](https://shiny.posit.co/) context.

  - `layerId` is now the base on which the actual layerId is built, with
    each real layerId in the form BASE-LN-PN where LN is the line number
    and PN is the point number. For example, if `layerId = "traj"`, the
    first point of the first line has the ID `"traj-1-1"`, the second
    point of the first line has ID `"traj-1-2"`, the first point of the
    second line has ID `"traj-2-1"`, and so on.

- “illegal” file path characters can now be used in the columns provided
  to the `type` argument of the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family. Most relevant to most users is that this will allow them to
  provide their own custom HTML tags - e.g., for formatting
  superscripts, subscripts, and so on.
  ([\#63](https://github.com/openair-project/openairmaps/issues/63))

- The colours in the legend of
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  now better align with the actual colours of the markers, and the layer
  control menu when `control = "variable"` is now presented in a nicer
  order with clearer labels.

## openairmaps 0.8.1

CRAN release: 2023-11-03

This is a minor release of
[openairmaps](https://openair-project.github.io/openairmaps/), released
mainly to fix an issue with [ggmap](https://github.com/dkahle/ggmap) but
also adding some new functionality for polar marker maps.

### Breaking changes

- BREAKING: The arguments of
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  have been rejigged to move “data” after “pollutant”, owing to the new
  use of
  [`leaflet::getMapData()`](https://rstudio.github.io/leaflet/reference/getMapData.html).
  ([\#45](https://github.com/openair-project/openairmaps/issues/45))

- BREAKING: The default arguments of some
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)-family
  functions have changed from, e.g., `NULL` to `"free"` or `"fixed"`.
  ([\#34](https://github.com/openair-project/openairmaps/issues/34))

- BREAKING: Due to changes in [ggmap](https://github.com/dkahle/ggmap),
  all static polar plotting functions now require users to provide their
  own `ggmap` object. The `zoom` argument has also been removed. This is
  specifically related to the partnership of Stamen and Stadia which has
  put the stamen tiles behind an API. See
  <https://maps.stamen.com/stadia-partnership/> and
  <https://github.com/dkahle/ggmap/issues/353> for more information.
  ([\#52](https://github.com/openair-project/openairmaps/issues/52))

### New features

- Several “limit” arguments can now take one of three options: “fixed”
  (which forces all markers to share scales), “free” (which allows them
  to use different scales), or a numeric vector to define the scales.
  ([\#34](https://github.com/openair-project/openairmaps/issues/34))
  These arguments and their defaults include:

  - [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md):
    `upper` (fixed); `limits` (free)
  - [`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md):
    `limits` (free)
  - [`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md):
    `breaks` (free)
  - [`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md):
    `intervals` (fixed)

- Added `searchNetwork()`, which allows users to find local air quality
  monitoring sites by specifying a target latitude and longitude.
  Function arguments allow the site metadata to be subset (for example,
  by site type, pollutants measured, or distance from the target).

- Added
  [`convertPostcode()`](https://openair-project.github.io/openairmaps/reference/convertPostcode.md),
  which converts a valid UK postcode to a latitude/longitude pair. This
  is intended to be used with `searchNetwork()`.

- The “data” argument of
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  and
  [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  and both the “before” and “after” arguments of
  [`addPolarDiffMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  now default to `leaflet::getMapData(map)`. This makes their use less
  verbose when creating multiple polar plots with the same underlying
  data, which will likely be a common use-case.
  ([\#45](https://github.com/openair-project/openairmaps/issues/45))

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  popups now contain links to the associated network websites. For
  example, the popup for London Marylebone Road in `networkMap("aurn")`
  now contains a link to
  <https://uk-air.defra.gov.uk/networks/site-info?site_id=MY1>. All
  networks are supported with the exception of “europe”.
  ([\#39](https://github.com/openair-project/openairmaps/issues/39))

- [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  and
  [`addPolarDiffMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  now have all of the “options” arguments of
  [`leaflet::addMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html).
  This means that, for example, polar markers can be clustered
  (<https://leafletjs.com/reference.html#marker>).
  ([\#38](https://github.com/openair-project/openairmaps/issues/38))

- The
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family and
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  `provider` argument can now take a named vector. The names will be
  used in the layer control menu, if `length(provider) > 1`.
  ([\#42](https://github.com/openair-project/openairmaps/issues/42))

## openairmaps 0.8.0

CRAN release: 2023-03-31

This is a minor release adding a range of quality of life features,
adding two new experimental functions, and fixing a few bugs.

### New features

- `trajMapStatic()` and `trajLevelMapStatic()` have been added as two
  new *experimental* functions to provide
  [ggplot2](https://ggplot2.tidyverse.org) equivalents of
  [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
  and
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html).
  ([\#28](https://github.com/openair-project/openairmaps/issues/28))

  - These are experimental as the long term place for these functions is
    uncertain; there will definitely be need for a
    [ggplot2](https://ggplot2.tidyverse.org) incarnation of the
    trajectory plotting functions, but whether they will sit in
    [openair](https://openair-project.github.io/openair/), `{ggopenair}`
    or [openairmaps](https://openair-project.github.io/openairmaps/) and
    what they will be named is not clear.

- The `control` and `facet` arguments of all polar marker mapping
  functions (static and interactive) and trajectory mapping functions
  are now passed to
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html).

- The `popup` argument of all interactive polar marker mapping functions
  can now take a vector of column names. If more than one column is
  provided, it is automatically passed to
  [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  using its default values.

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now has the `control` argument, which maps directly onto the `type`
  argument of
  [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html).
  Like other `control` arguments elsewhere in
  [openairmaps](https://openair-project.github.io/openairmaps/), this
  creates a “layer control” menu.

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  now uses different coloured markers for different networks. If more
  than one network is specified, and `draw.legend` is set to `TRUE`, a
  legend will also be drawn for quick identification of different data
  sources.
  ([\#30](https://github.com/openair-project/openairmaps/issues/30))

- Deprecations are now managed by the
  [lifecycle](https://lifecycle.r-lib.org/) package. This currently only
  applies to the `type` argument.

### Bug fixes

- Fixed issues where multiple
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  chained together would all show the same plot.

- Fixed issue where `...` and `pollutant` weren’t being passed to
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md).
  ([\#27](https://github.com/openair-project/openairmaps/issues/27))

- Fixed issue in
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  caused by recent updates to [dplyr](https://dplyr.tidyverse.org) and
  [forcats](https://forcats.tidyverse.org/).

- Fixed issue where `polarMapStatic()` and others would turn factor
  facet levels into characters.

  - Specifically, this meant that, for example, months of the year would
    be in alphabetical order. Now factor levels, including those
    resulting from a pass to
    [`cutData()`](https://openair-project.github.io/openair/reference/cutData.html),
    will now be honoured by the `facet` argument.
    ([\#31](https://github.com/openair-project/openairmaps/issues/31))

- Fixed issue where `polarMapStatic()` and others would error when
  trying to draw a legend.

## openairmaps 0.7.0

CRAN release: 2023-02-09

This is a minor release containing several important new features that
expand the scope of the package. This also comes with several minor
breaking changes to improve consistency within
[openairmaps](https://openair-project.github.io/openairmaps/) and with
[openair](https://openair-project.github.io/openair/).

### Breaking changes

- BREAKING: The `fig.width`, `fig.height`, `iconHeight` and `iconWidth`
  arguments have been replaced with `d.fig` and `d.icon`. There are two
  main justifications behind this:

  - This ensures consistency across all of
    [openairmaps](https://openair-project.github.io/openairmaps/),
    making it easier to switch between the static and HTML map types.

  - Polar markers are almost always going to be circular (i.e., width =
    height) so having one argument will streamline things. If users wish
    to have non-circular markers, a vector of length two in the form
    `c(width, height)` will provide the same functionality.

- BREAKING: The arguments in
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  have been put in a more sensible order, leading with `data`,
  `pollutant` and `fun`.

- BREAKING: The `date` argument from
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  has been replaced by `year`.
  ([\#26](https://github.com/openair-project/openairmaps/issues/26))

### New features

- Added “static” equivalents of all of the polar marker maps written in
  [ggplot2](https://ggplot2.tidyverse.org). While interactive HTML maps
  are preferred, the static equivalents may be more appropriate for,
  e.g., academic publications.
  ([\#19](https://github.com/openair-project/openairmaps/issues/19))

  - The [ggplot2](https://ggplot2.tidyverse.org) functions can be
    identified by “Static” being appended to the function name. For
    example,
    [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
    is the [leaflet](https://rstudio.github.io/leaflet/) polar plot map,
    whereas `polarMapStatic()` is the
    [ggplot2](https://ggplot2.tidyverse.org) equivalent.

  - Currently, “static” versions of the trajectory maps are served by
    [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
    and
    [`openair::trajLevel()`](https://openair-project.github.io/openair/reference/trajLevel.html),
    but there may be space in future to have `ggmap` equivalents of
    these in `openairmaps`.

- Added
  [`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md)
  and `diffMapStatic()` which are to
  [`openair::polarDiff()`](https://openair-project.github.io/openair/reference/polarDiff.html)
  what
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and `polarMapStatic()` are to
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  ([\#17](https://github.com/openair-project/openairmaps/issues/17)).
  Also added
  [`addPolarDiffMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md),
  which is the equivalent of
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md).
  ([\#25](https://github.com/openair-project/openairmaps/issues/25))

- Added `alpha` as an argument to all of the directional analysis polar
  mapping functions, not just
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).
  ([\#14](https://github.com/openair-project/openairmaps/issues/14))

- Fixed `alpha` to work on both Windows and MacOS by forcing the use of
  the “cairo” device to save plots.
  ([\#14](https://github.com/openair-project/openairmaps/issues/14))

- Polar marker maps and
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  now show a progress bar when creating the markers takes more than a
  few seconds (most commonly in
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  and
  [`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md),
  particularly with multiple pollutants/control groups).

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  can now pass the new `year` option to
  [`importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html).

## openairmaps 0.6.1

CRAN release: 2023-01-09

This is a patch release primarily to fix a few bugs in
[openairmaps](https://openair-project.github.io/openairmaps/), and
implement a new default colour scheme after a recent
[openair](https://openair-project.github.io/openair/) update.

### New features

- Functions now use the `"turbo"` colour palette rather than `"jet"` by
  default, which is still a rainbow palette but with more perceptually
  uniform colours.

### Bug fixes

- Fixed issue with polar marker maps (e.g.,
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md))
  and the generic
  [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  function where lat/lon info in the Southern Hemisphere would misalign
  markers. Hat tip to Deanna Tuxford and James for noticing this issue.
  ([\#18](https://github.com/openair-project/openairmaps/issues/18))

- Fixed an issue with
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  where `control = "variable"` would fail to show all pollutants.

## openairmaps 0.6.0

CRAN release: 2022-11-28

This is a minor release, mainly focusing on enhancing the ability for
polar markers to have shared colour scales, but also incorporating new
features for network visualisation.

### New features

- All directional analysis maps can now have their limits provided (can
  be “limits”, “breaks”, “percentiles”, etc., depending on function).
  This was always possible through `...`, but it is now explicitly
  listed as an option.
  ([\#12](https://github.com/openair-project/openairmaps/issues/12))

- If limits are defined in a directional analysis function, a shared
  legend will now be drawn at the top-right of the map. This
  functionality can be disabled by setting `draw.legend` to FALSE.
  ([\#12](https://github.com/openair-project/openairmaps/issues/12))

- Added the
  [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  function, which allows users to easily construct HTML popups for use
  with the “popup” argument of directional analysis maps (or `leaflet`
  maps more widely).

- The default options for fig.width and fig.height are now `3.5` rather
  than `4`. This appears to remove some visual artefacts and makes the
  axis labels more legible.

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  now supports multiple sources. For example, using
  `source = c("aurn", "saqn")` will show both the AURN and SAQN on one
  map. This may be useful if users are interested in air quality in a
  specific region of the UK (e.g., users may wish to locate AURN, AQE
  *and* locally managed sites near to a given urban centre).
  ([\#16](https://github.com/openair-project/openairmaps/issues/16))

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  now supports `source = "local"`.

- Multiple basemap providers can now be used with
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md).

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md),
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and all polar directional analysis maps have gained the
  `collapse.control` argument, which controls whether the control menu
  starts collapsed or not. It defaults to `FALSE`, which means the
  control menu is not collapsed.

- All documentation has been improved; function parameters are more
  consistent between functions and arguments passed to `openair` via
  `...` are now explicitly listed.

### Bug fixes

- The “alpha” option has been removed for all directional analysis
  functions except
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  as it only ever worked for
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md).

## openairmaps 0.5.1

CRAN release: 2022-10-20

This is a patch release designed to fix a major bug in v0.5.0.

### Bug fixes

- Fixed an issue causing markers to be duplicated when pollutant
  information is missing for certain sites.

## openairmaps 0.5.0

CRAN release: 2022-10-19

This is a minor release centred around the addition of the `control`
argument, which allows for arbitrary columns to be used in “layer
control” menus.

### Breaking changes

- All functions now use latitude and longitude to distinguish between
  site types. Therefore, “type” is now deprecated. Maps using the old
  system will still render, but popups will not be displayed. For most
  users, to restore previous site labels simply rewrite `type = "site"`
  as `popup = "site"`.
  ([\#10](https://github.com/openair-project/openairmaps/issues/10))

- The default values for “pollutant” have all been removed. Any users
  relying on this default should update their code to explicitly state
  `pollutant = "nox"`.

### New features

- All functions now possess the “control” argument, which allows users
  to create a “layer control” menu with any arbitrary column.
  Appropriate columns may be those produced using
  [`openair::cutData()`](https://openair-project.github.io/openair/reference/cutData.html),
  [`openair::splitByDate()`](https://openair-project.github.io/openair/reference/splitByDate.html),
  or a user-defined
  [`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)/[`dplyr::if_else()`](https://dplyr.tidyverse.org/reference/if_else.html)
  column transformation.
  ([\#9](https://github.com/openair-project/openairmaps/issues/9))

- All functions now possess the “popup” and “label” arguments, which
  control pop-up and hover-over labels, respectively. This allows users
  to define *any* popup or label column, even non-unique ones. For
  example, multiple sites can be labelled with identical site types.
  ([\#10](https://github.com/openair-project/openairmaps/issues/10))

- All functions now try to guess the latitude/longitude column if not
  provided, similar to [leaflet](https://rstudio.github.io/leaflet/).
  ([\#10](https://github.com/openair-project/openairmaps/issues/10))

- Updated many error messages and warnings to use
  [cli](https://cli.r-lib.org) and be broadly more descriptive.

### Bug fixes

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  can now be coloured by date.

- Fixed issue with
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  that would cause user-defined colours not to work.

## openairmaps 0.4.3

CRAN release: 2022-09-13

This is a patch release adding a small number of refinements.

### Breaking changes

- `polar_data` column names changed from “latitude” to “longitude” to
  “lat” and “lon” to reflect the defaults of the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family.

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now use the argument names “latitude” and “longitude” to match those
  of the
  [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  family.

### New features

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now contains the `lat.inc` and `lon.inc` arguments.

## openairmaps 0.4.2

This is a patch release to fix a bug with
[`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md).

### Bug fixes

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  now works where `statistic = "frequency"` without a “pollutant”.

## openairmaps 0.4.1

This is the first CRAN release of
[openairmaps](https://openair-project.github.io/openairmaps/).

### Features

- There are currently three streams of functionality in `openairmaps`:

  - [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
    visualises any of the
    [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
    networks.

  - [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
    and family allow for any of the `openair` directional analysis plots
    to be used as leaflet markers.

  - [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
    and family are leaflet equivalents to
    [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
    and `openair::trajMap()`.

- There are two main classes of functions:

  - `*Map()` functions are easy-to-use functions which create leaflet
    maps from the ground-up. These are the most similar to `openair`
    functions.

  - `add*()` functions are more flexible and allow users to add layers
    to existing leaflet maps. These are designed to be similar to the
    `leaflet` “add” functions like
    [`addMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html).
