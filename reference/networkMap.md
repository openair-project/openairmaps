# Create a leaflet map of air quality measurement network sites

This function uses
[`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
to obtain metadata for measurement sites and uses it to create an
attractive `leaflet` map. By default a map will be created in which
readers may toggle between a vector base map and a satellite/aerial
image, although users can further customise the control menu using the
`provider` and `control` parameters.

## Usage

``` r
networkMap(
  source = "aurn",
  control = NULL,
  year = NULL,
  cluster = TRUE,
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

- control:

  *Option to create a 'layer control' menu.*

  *default*: `NULL`

  A string to specify categories in a "layer control" menu, to allow
  readers to select between different site categories. Choices include:

  - `"variable"` to toggle between different pollutants

  - `"site_type"` for different site classifications

  - `"agglomeration"`, `"zone"` or `"local_authority"` for different
    regions of the UK

  - `"network"` for different monitoring networks, if more than one
    `source` is provided.

- year:

  *A year, or range of years, with which to filter data.*

  *default*: `NULL`

  By default, `networkMap()` visualises sites which are currently
  operational. `year` allows users to show sites open in a specific
  year, or over a range of years. See
  [`openair::importMeta()`](https://openair-project.github.io/openair/reference/importMeta.html)
  for more information.

- cluster:

  *Cluster markers together when zoomed out?*

  *default:* `TRUE`

  When `cluster = TRUE`, markers are clustered together. This may be
  useful for sources like `"imperial"` where there are many markers very
  close together. Defaults to `TRUE`, and is forced to be `TRUE` when
  `source = "europe"` due to the large number of sites.

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

## Details

When selecting multiple data sources using `source`, please be mindful
that there can be overlap between the different networks. For example,
an air quality site in Scotland may be part of the AURN *and* the SAQN.
`networkMap()` will only show one marker for such sites, and uses the
order in which `source` arguments are provided as the hierarchy by which
to assign sites to networks. The aforementioned AURN & SAQN site will
therefore have its SAQN code displayed if `source = c("saqn", "aurn")`,
and its AURN code displayed if `source = c("aurn", "saqn")`.

This hierarchy is also reflected when `control = "network"` is used. As
`leaflet` markers cannot be part of multiple groups, the AURN & SAQN
site will be part of the "SAQN" layer control group when
`source = c("saqn", "aurn")` and the "AURN" layer control group when
`source = c("aurn", "saqn")`.

## See also

Other uk air quality network mapping functions:
[`searchNetwork()`](https://openair-project.github.io/openairmaps/reference/searchNetwork.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# view one network, grouped by site type
networkMap(source = "aurn", control = "site_type")

# view multiple networks, grouped by network
networkMap(source = c("aurn", "waqn", "saqn"), control = "network")
} # }
```
