# Package index

## Data

In-built data to demonstrate openair functions.

- [`polar_data`](https://openair-project.github.io/openairmaps/reference/polar_data.md)
  : Example data for polar mapping functions
- [`traj_data`](https://openair-project.github.io/openairmaps/reference/traj_data.md)
  : Example data for trajectory mapping functions

## Network Visualisation

Quickly visualise UK air quality networks.

- [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  : Create a leaflet map of air quality measurement network sites

- [`searchNetwork()`](https://openair-project.github.io/openairmaps/reference/searchNetwork.md)
  :

  Geographically search the air quality networks made available by
  [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)

## Directional Analysis

Create HTML `leaflet` and static `ggplot2` maps with polar plot markers.

- [`annulusMap()`](https://openair-project.github.io/openairmaps/reference/annulusMap.md)
  : Polar annulus plots on dynamic and static maps
- [`diffMap()`](https://openair-project.github.io/openairmaps/reference/diffMap.md)
  : Bivariate polar 'difference' plots on dynamic and static maps
- [`freqMap()`](https://openair-project.github.io/openairmaps/reference/freqMap.md)
  : Polar frequency plots on dynamic and static maps
- [`percentileMap()`](https://openair-project.github.io/openairmaps/reference/percentileMap.md)
  : Percentile roses on dynamic and static maps
- [`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md)
  : Bivariate polar plots on dynamic and static maps
- [`pollroseMap()`](https://openair-project.github.io/openairmaps/reference/pollroseMap.md)
  : Pollution roses on dynamic and static maps
- [`windroseMap()`](https://openair-project.github.io/openairmaps/reference/windroseMap.md)
  : Wind roses on dynamic and static maps
- [`addPolarMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  [`addPolarDiffMarkers()`](https://openair-project.github.io/openairmaps/reference/addPolarMarkers.md)
  : Add polar markers to leaflet map

## Trajectory Analysis

Create HTML `leaflet` and static `ggplot2` maps of HYSPLIT trajectories.

- [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md)
  :

  Trajectory level plots in `leaflet`

- [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  :

  Trajectory line plots in `leaflet`

- [`trajLevelMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajLevelMapStatic.md)
  **\[experimental\]** :

  Trajectory level plots in `ggplot2`

- [`trajMapStatic()`](https://openair-project.github.io/openairmaps/reference/trajMapStatic.md)
  **\[experimental\]** :

  Trajectory line plots in `ggplot2`

- [`addTrajPaths()`](https://openair-project.github.io/openairmaps/reference/addTrajPaths.md)
  : Add trajectory paths to leaflet map

## Spatial Interpolation

Create HTML `leaflet` and static `ggplot2` maps of spatially
interpolated pollution data.

- [`krigingMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  [`voronoiMap()`](https://openair-project.github.io/openairmaps/reference/interpolate-map.md)
  **\[experimental\]** : Spatially interpolated dynamic and static maps

## Utilities

Tools to assist other openairmaps functions.

- [`buildPopup()`](https://openair-project.github.io/openairmaps/reference/buildPopup.md)
  : Build a Complex Popup for a Leaflet Map

- [`quickTextHTML()`](https://openair-project.github.io/openairmaps/reference/quickTextHTML.md)
  :

  Automatic text formatting for `openairmaps`

- [`convertPostcode()`](https://openair-project.github.io/openairmaps/reference/convertPostcode.md)
  : Convert a UK postcode to a latitude/longitude pair

## Deprecated

Functions which are no longer recommended for use.

- [`polarMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`diffMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`annulusMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`windroseMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`pollroseMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`percentileMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  [`freqMapStatic()`](https://openair-project.github.io/openairmaps/reference/deprecated-static-polar-maps.md)
  **\[deprecated\]** : Deprecated static directional analysis functions
