# Create a leaflet map of air quality measurement network sites

This function uses
[`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
to obtain metadata for measurement sites and uses it to create an
interactive `leaflet` map. By default a map will be created in which
readers may toggle between a vector base map and a satellite/aerial
image, although users can further customise the control menu using the
`provider` and `control` parameters. Any argument which can be passed to
[`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
can be passed via `...`, with the exception of `all` and `duplicate`.

## Usage

``` r
networkMap(
  source = "aurn",
  ...,
  control = NULL,
  cluster = NULL,
  provider = c(Default = "OpenStreetMap", Satellite = "Esri.WorldImagery"),
  legend = TRUE,
  legend.position = "topright",
  control.collapsed = FALSE,
  control.position = "topright"
)
```

## Arguments

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

- ...:

  Arguments passed on to
  [`openair::importMeta`](https://openair-project.github.io/openair/reference/importMeta.html)

  `year`

  :   If a single year is selected, only sites that were open at some
      point in that year are returned. If `all = TRUE` only sites that
      measured a particular pollutant in that year are returned. Year
      can also be a sequence e.g. `year = 2010:2020` or of length 2 e.g.
      `year = c(2010, 2020)`, which will return only sites that were
      open over the duration.

  `pollutant`

  :   Character vectors used to search the metadata for the specified
      `source`s. `pollutant` is case-insensitive. For example,
      `pollutant = c("nox", "o3")` will return sites which measure
      *either* NOx *or* O3. Can also take the shorthand `"hc"`, will
      returns all hydrocarbons. Similar to `code`, values are matched
      exactly (e.g., `pollutant = "no"` will only return NO and not NO2
      or NOx). Note that `pollutant` only applies to networks available
      through
      [`importUKAQ()`](https://openair-project.github.io/openair/reference/importUKAQ.html).

  `site,code,site_type`

  :   Character vectors used to search the metadata for the specified
      `source`s. All of `code`, `site` and `site_type` are
      case-insensitive. `code` and `site_type` are matched exactly, but
      `site` is 'pattern matched' - e.g., `site = "Sunderland"` and
      `source = "aurn"` will return data for `"Sunderland"`,
      `"Sunderland Silksworth"` and `"Sunderland Wessington Way"` (plus
      any future sites with the string `"Sunderland"` in their name).

  `lat,lng`

  :   Decimal latitude (`lat`) and longitude (`lng`) (or other Y/X
      coordinate if using a different `crs`). If provided, the data will
      be returned with a `distance_km` column displaying the distance of
      each station from the target coordinate. The data will also be
      automatically sorted by this column.

  `crs`

  :   The coordinate reference system (CRS) of the data, passed to
      [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html).
      By default this is [EPSG:4326](https://epsg.io/4326), the CRS
      associated with the commonly used latitude and longitude
      coordinates. Different coordinate systems can be specified using
      `crs` (e.g., `crs = 27700` for the British National Grid). Note
      that non-lat/lng coordinate systems will be re-projected to
      EPSG:4326 for comparison with the site metadata.

  `max_dist,max_n`

  :   If `lat` and `lng` are provided, `max_dist` and `max_n` further
      filter the metadata. `max_dist` defines a maximum distance from
      the target coordinate in kilometers, and `max_n` a maximum number
      of sites to be returned. `max_n` is applied after `max_dist`.

- control:

  *Option to create a 'layer control' menu.*

  *default*: `NULL`

  A string to specify categories in a "layer control" menu, to allow
  readers to select between different site categories. Choices include:

  - `"source"` to toggle between different networks

  - `"variable"` to toggle between different pollutants

  - `"site_type"` for different site classifications

  - `"agglomeration"`, `"zone"` or `"local_authority"` for different
    regions of the UK

- cluster:

  *Cluster markers together when zoomed out?*

  *default:* `NULL`

  When `cluster = TRUE`, markers are clustered together. This may be
  useful for sources like `"imperial"` where there are many markers very
  close together. Defaults to `NULL`, which is `TRUE` if there are more
  than 25 sites mapped and `FALSE` if there are fewer.

- provider:

  *The basemap(s) to be used.*

  *default:*
  `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`

  Any number of
  [leaflet::providers](https://rstudio.github.io/leaflet/reference/providers.html).
  See <http://leaflet-extras.github.io/leaflet-providers/preview/> for a
  list of all base maps that can be used. If multiple base maps are
  provided, they can be toggled between using a "layer control"
  interface. By default, the interface will use the provider names as
  labels, but users can define their own using a named vector (e.g.,
  `c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")`)

- legend:

  *Draw a shared legend?*

  *default:* `TRUE`

  When multiple `source`s are defined, should a shared legend be created
  at the side of the map?

- legend.position:

  *Position of the legend*

  *default:* `"topright"`

  Where should the shared legend be placed? One of "topleft",
  "topright", "bottomleft" or "bottomright". Passed to the `position`
  argument of
  [`leaflet::addLayersControl()`](https://rstudio.github.io/leaflet/reference/addLayersControl.html).

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

## Examples

``` r
if (FALSE) { # \dontrun{
# view one network, grouped by site type
networkMap(source = "aurn", control = "site_type")

# view multiple networks, grouped by network
networkMap(source = c("aurn", "waqn", "saqn"), control = "network")
} # }
```
