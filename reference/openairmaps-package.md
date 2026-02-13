# openairmaps: Create Maps of Air Pollution Data

Combine the air quality data analysis methods of 'openair' with the
JavaScript 'Leaflet' (<https://leafletjs.com/>) library. Functionality
includes plotting site maps, "directional analysis" figures such as
polar plots, and air mass trajectories.

## Details

This is a companion package to `openair`, a UK NERC- and Defra-funded R
package for the analysis of data pertaining to pollution monitoring and
dispersion modelling.

As the R ecosystem has developed, R Markdown and, more recently, Quarto
have emerged as capable tools for combining data analysis with document
preparation. While these approaches can render typical .docx and .pdf
outputs, one of their most common output formats is the HTML document.
This format has many strengths, but a key one is interactivity; HTML
widgets allow documents to be more informative and engaging. Numerous
packages have been developed to easily develop these interactive
widgets, such as `plotly` and `dygraphs` for plots, `DT` for tables, and
`leaflet` for maps. The `openairmaps` package concerns itself with
making `leaflet` maps.

Air quality data analysis — particularly as it pertains to long term
monitoring data — naturally lends itself to being visualised spatially
on a map. Monitoring networks are geographically distributed, and
ignoring their geographical context may lead to incomplete insights at
best and incorrect conclusions at worst! Furthermore, many air quality
analysis tools are directional, asking questions of the data along the
lines of “do elevated concentrations come from the North, South, East or
West?” The natural question that follows is “well, what actually is it
to the North/South/East/West that could be causing elevated
concentrations?” — a map can help answer that question
straightforwardly.

The `openairmaps` package contains functions to visualise UK air quality
networks, and place "polar analysis" markers (like the `openair` [polar
plot](https://openair-project.github.io/openair/reference/polarPlot.html))
and airmass trajectory paths on maps. It uses a similar syntax to the
`openair` package, which should make moving between the two relatively
seamless.

## See also

The `openair` package, from which `openairmaps` is based.

The `worldmet` package, which simplifies the access of meteorological
data in R.

The [openair book](https://openair-project.github.io/book/) for more
in-depth documentation of `openair` and `openairmaps`.

## Author

**Maintainer**: Jack Davison <jack.davison@ricardo.com>
([ORCID](https://orcid.org/0000-0003-2653-6615))

Authors:

- David Carslaw <david.carslaw@york.ac.uk>
  ([ORCID](https://orcid.org/0000-0003-0991-950X))
