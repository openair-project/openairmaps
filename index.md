![](reference/figures/logo.png)

## **openairmaps**

### open source tools to create maps of air pollution data

**openairmaps** combines the robust analytical methods found in
[**openair**](https://openair-project.github.io/openair/) with a range
of dynamic and static mapping capability. Core functionality includes
visualising UK AQ networks
([`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md)),
putting “polar directional markers” on maps (e.g.,
[`polarMap()`](https://openair-project.github.io/openairmaps/reference/polarMap.md))
and overlaying HYSPLIT trajectories on maps (e.g.,
[`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)),
all using the [leaflet](https://rstudio.github.io/leaflet/) package.
Static equivalents of most functions are also available for insertion
into traditional reports and academic articles.

*Part of the openair toolkit*

[![openair](https://img.shields.io/badge/openair_core-06D6A0?style=flat-square)](https://openair-project.github.io/openair/)
\|
[![worldmet](https://img.shields.io/badge/worldmet-26547C?style=flat-square)](https://openair-project.github.io/worldmet/)
\|
[![openairmaps](https://img.shields.io/badge/openairmaps-FFD166?style=flat-square)](https://openair-project.github.io/openairmaps/)
\|
[![deweather](https://img.shields.io/badge/deweather-EF476F?style=flat-square)](https://openair-project.github.io/deweather/)

------------------------------------------------------------------------

## 💡 Core Features

**openairmaps** has developed at pace to align **openair** with R’s
modern geospatial ecosystem.

- **Network visualisation** of many UK-based monitoring networks through
  [`networkMap()`](https://openair-project.github.io/openairmaps/reference/networkMap.md),
  all of which can also be searched using
  [`searchNetwork()`](https://openair-project.github.io/openairmaps/reference/searchNetwork.md).

- **Directional analysis maps** to place
  [`openair::polarPlot()`](https://openair-project.github.io/openair/reference/polarPlot.html)
  and other “polar coordinate” plots on maps.

- **Trajectory analysis maps** (such as
  [`trajMap()`](https://openair-project.github.io/openairmaps/reference/trajMap.md)
  and
  [`trajLevelMap()`](https://openair-project.github.io/openairmaps/reference/trajLevelMap.md))
  for interactive implementations of the
  [`openair::trajPlot()`](https://openair-project.github.io/openair/reference/trajPlot.html)
  family.

- **Flexible map conditioning** aligned with the **openair** `type`
  option to easily condition maps by season, day of the week, and so on.

- **Map building utilities** such as building popups for interactive
  maps, formatting common pollutant names and units, and converting UK
  postcodes to lat/lng coordinates.

![](reference/figures/feature-banner.png)

------------------------------------------------------------------------

## 📖 Documentation

All **openairmaps** functions are fully documented; access documentation
using R in your IDE of choice.

``` r
?openairmaps::polarMap
```

Documentation is also hosted online on the **package website**.

[![website](https://img.shields.io/badge/website-documentation-blue)](https://openair-project.github.io/openairmaps/)

A guide to the openair toolkit can be found in the **online book**,
which contains lots of code snippets, demonstrations of functionality,
and ideas for the application of **openair**’s various functions.

[![book](https://img.shields.io/badge/book-code_demos_and_ideas-blue)](https://openair-project.github.io/book/)

------------------------------------------------------------------------

## 🗃️ Installation

**openairmaps** can be installed from **CRAN** with:

``` r
install.packages("openairmaps")
```

You can also install the development version of **openairmaps** from
GitHub using [pak](https://pak.r-lib.org/):

``` r
# install.packages("pak")
pak::pak("openair-project/openairmaps")
```

------------------------------------------------------------------------

🏛️ **openairmaps** is primarily maintained by [Jack
Davison](https://github.com/jack-davison).

📃 **openairmaps** is licensed under the [MIT
License](https://openair-project.github.io/openairmaps/LICENSE.html).

🧑‍💻 Contributions are welcome from the wider community. See the
[contributing
guide](https://openair-project.github.io/openairmaps/CONTRIBUTING.html)
and [code of
conduct](https://openair-project.github.io/openairmaps/CODE_OF_CONDUCT.html)
for more information.
