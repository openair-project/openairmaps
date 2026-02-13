# Geographically search the air quality networks made available by [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)

While
[`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
visualises entire UK air quality networks, `searchNetwork()` can subset
specific networks to find air quality sites near to a specific site of
interest (for example, the location of known industrial activity, or the
centroid of a specific urban area).

## Usage

``` r
searchNetwork(
  lat,
  lng,
  source = "aurn",
  year = NULL,
  site_type = NULL,
  variable = NULL,
  max_dist = NULL,
  n = NULL,
  crs = 4326,
  map = TRUE
)
```

## Arguments

- lat, lng:

  *The decimal latitude(Y)/longitude(X).*

  **required**

  Values representing the decimal latitude and longitude (or other Y/X
  coordinate if using a different `crs`) of the site of interest.

- source:

  *One or more UK or European monitoring networks.*

  *default:* `"aurn"`

  One or more air quality networks for which data is available through
  openair. Available networks include:

  - `"aurn"`, The UK Automatic Urban and Rural Network.

  - `"aqe"`, The Air Quality England Network.

  - `"saqn"`, The Scottish Air Quality Network.

  - `"waqn"`, The Welsh Air Quality Network.

  - `"ni"`, The Northern Ireland Air Quality Network.

  - `"local"`, Locally managed air quality networks in England.

  - `"imperial"`, Imperial College London (formerly King's College
    London) networks.

  - `"europe"`, European AirBase/e-reporting data.

  There are two additional options provided for convenience:

  - `"ukaq"` will return metadata for all networks for which data is
    imported by importUKAQ() (i.e., AURN, AQE, SAQN, WAQN, NI, and the
    local networks).

  - `"all"` will import all available metadata (i.e., "ukaq" plus "kcl"
    and "europe").

- year:

  *A year, or range of years, with which to filter data.*

  *default*: `NULL`

  By default,
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)
  visualises sites which are currently operational. `year` allows users
  to show sites open in a specific year, or over a range of years. See
  [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
  for more information.

- site_type:

  *One or more site types with which to subset the site metadata.*

  *default:* `NULL`

  If `site_type` is specified, only sites of that type will be searched
  for. For example, `site_type = "urban background"` will only search
  urban background sites.

- variable:

  *One or more variables of interest with which to subset the site
  metadata.*

  *default:* `NULL`

  If `variable` is specified, only sites measuring at least one of these
  pollutants will be searched for. For example,
  `variable = c("pm10", "co")` will search sites that measure PM10
  and/or CO.

- max_dist:

  *A maximum distance from the location of interest in kilometres.*

  *default:* `NULL`

  If `max_dist` is specified, only sites within `max_dist` kilometres
  from the `lat` / `lng` coordinate will be searched for.

- n:

  *The maximum number of sites to return.*

  *default:* `NULL`

  If `n` is specified, only `n` sites will be returned. Note that this
  filtering step is applied last, after `site_type`, `variable`, and
  `max_dist`.

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

- map:

  *Return a map?*

  *default:* `TRUE`

  If `TRUE`, the default, `searchNetwork()` will return a `leaflet` map.
  If `FALSE`, it will instead return a
  [tibble](https://tibble.tidyverse.org/reference/tibble-package.html).

## Value

Either a
[tibble](https://tibble.tidyverse.org/reference/tibble-package.html) or
`leaflet` map.

## Details

Data subsetting progresses in the order in which the arguments are
given; first `source` and `year`, then `site_type` and `variable`, then
`max_dist`, and finally `n`.

## See also

Other uk air quality network mapping functions:
[`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# get all AURN sites open in 2020 within 20 km of Buckingham Palace
palace <- convertPostcode("SW1A1AA")
searchNetwork(lat = palace$lat, lng = palace$lng, max_dist = 20, year = 2020)
} # }
```
