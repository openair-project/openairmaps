
<!-- README.md is generated from README.Rmd. Please edit that file -->

# openairmaps

The goal of `openairmaps` is to combine the robust analytical methods
found in [openair](https://davidcarslaw.github.io/openair/) with the
highly capable `leaflet` package.

## Installation

You can install the development version of `openairmaps` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("davidcarslaw/openairmaps")
```

## Example

`openairmaps` makes it simple to place polar plots on an interactive
`leaflet` map. A static screenshot is provided below, but if the below
code is run in your R session you’ll find the map can be scrolled,
zoomed and otherwise interacted with.

``` r
library(openairmaps)

polarMap(
  polar_data, 
  latitude = "latitude", 
  longitude = "longitude",
  type = "site"
)
```

![A screenshot of `polarMap()` output.](man/figures/README-polarmap.png)

Multiple pollutants and/or base-maps can be provided, which uses the
`leaflet` package’s “layer control” interface to allow users to toggle
between them.

``` r
annulusMap(
  polar_data,
  pollutant = c("no2", "nox"),
  provider = c("CartoDB.Positron", "OpenStreetMap"),
  latitude = "latitude", 
  longitude = "longitude",
  type = "site"
)
```

![A screenshot of `annulusMap()` output, with a layer control
menu.](man/figures/README-annuluslayers.png)

As `openairmaps` outputs `leaflet` maps, you can use `leaflet`’s own
functions to further customise your `openairmaps` outputs.

``` r
polarMap(
  polar_data,
  pollutant = c("no2", "nox"),
  provider = c("CartoDB.Positron", "OpenStreetMap"),
  latitude = "latitude", 
  longitude = "longitude",
  type = "site"
) %>% 
  leaflet::popupOptions(...) %>% 
  leaflet::mapOptions(...) # etc.
```
