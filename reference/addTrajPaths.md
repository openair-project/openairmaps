# Add trajectory paths to leaflet map

This function is similar (but not identical to) the
[`leaflet::addMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
function in `leaflet`, which allows users to add trajectory paths to any
leaflet map and have more control over groups and layerIds than in
"all-in-one" functions like
[`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md).

## Usage

``` r
addTrajPaths(
  map,
  lng = "lon",
  lat = "lat",
  layerId = NULL,
  group = NULL,
  data = leaflet::getMapData(map),
  npoints = 12,
  ...
)
```

## Arguments

- map:

  a map widget object created from
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html).

- lng:

  The decimal longitude.

- lat:

  The decimal latitude.

- layerId:

  The base string for the layer id. The actual layer IDs will be in the
  format "layerId-linenum" for lines and "layerId_linenum-pointnum" for
  points. For example, the first point of the first trajectory path will
  be "layerId-1-1".

- group:

  the name of the group the newly created layers should belong to (for
  [`leaflet::clearGroup()`](https://rstudio.github.io/leaflet/reference/remove.html)
  and
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html)
  purposes). Human-friendly group names are permitted–they need not be
  short, identifier-style names. Any number of layers and even different
  types of layers (e.g. markers and polygons) can share the same group
  name.

- data:

  Data frame, the result of importing a trajectory file using
  [`openair::importTraj()`](https://openair-project.github.io/openair/reference/importTraj.html).
  By default, it is the data object provided to
  [`leaflet::leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
  initially, but can be overridden.

- npoints:

  A dot is placed every `npoints` along each full trajectory. For hourly
  back trajectories points are plotted every `npoints` hours. This helps
  to understand where the air masses were at particular times and get a
  feel for the speed of the air (points closer together correspond to
  slower moving air masses). Defaults to `12`.

- ...:

  Other arguments to pass to both
  [`leaflet::addCircleMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
  and
  [`leaflet::addPolylines()`](https://rstudio.github.io/leaflet/reference/map-layers.html).
  If you use the `color` argument, it is important to ensure the vector
  you supply is of length one to avoid issues with
  [`leaflet::addPolylines()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
  (i.e., use `color = ~ pal(nox)[1]`). Note that `opacity` controls the
  opacity of the lines and `fillOpacity` the opacity of the markers.

## Value

A leaflet object.

## Details

`addTrajPaths()` can be a powerful way of quickly plotting trajectories
on a leaflet map, but users should take some care due to any additional
arguments being passed to both
[`leaflet::addCircleMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
and
[`leaflet::addPolylines()`](https://rstudio.github.io/leaflet/reference/map-layers.html).
In particular, users should be weary of the use of the `color` argument.
Specifically, if `color` is passed a vector of length greater than one,
multiple polylines will be drawn on top of one another. At best this
will affect opacity, but at worst this will significantly impact the
performance of R and the final leaflet map.

To mitigate this, please ensure that any vector passed to `color` is of
length one. This is simple if you want the whole path to be the same
colour, but more difficult if you want to colour by a pollutant, for
example. The easiest way to achieve this is to write a for loop or use
another iterative approach (e.g. the `purrr` package) to add one path
per arrival date. An example of this is provided in the Examples.

## See also

`shiny::runExample(package = "openairmaps")` to see examples of this
function used in a
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html)

## Examples

``` r
if (FALSE) { # \dontrun{
library(leaflet)
library(openairmaps)

pal <- colorNumeric(palette = "viridis", domain = traj_data$nox)

map <- leaflet() |>
  addTiles()

for (i in seq(length(unique(traj_data$date)))) {
  data <- dplyr::filter(traj_data, date == unique(traj_data$date)[i])

  map <- map |>
    addTrajPaths(
      data = data,
      color = pal(data$nox)[1]
    )
}

map
} # }
```
