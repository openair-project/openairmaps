% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/polar_pollroseMap.R
\name{pollroseMap}
\alias{pollroseMap}
\title{Pollution roses on dynamic and static maps}
\usage{
pollroseMap(
  data,
  pollutant = NULL,
  statistic = "prop.count",
  breaks = NULL,
  latitude = NULL,
  longitude = NULL,
  crs = 4326,
  type = NULL,
  popup = NULL,
  label = NULL,
  provider = "OpenStreetMap",
  cols = "turbo",
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
  n.core = 1L,
  ...,
  control = NULL
)
}
\arguments{
\item{data}{\emph{Input data table with pollutant, wind, and geo-spatial
information.}

\strong{required} | \emph{scope:} dynamic & static

A data frame. The data frame must contain the data to plot the directional
analysis marker, which includes wind speed (\code{ws}), wind direction (\code{wd}),
and the column representing the concentration of a pollutant. In addition,
\code{data} must include a decimal latitude and longitude (or X/Y coordinate
used in conjunction with \code{crs}).}

\item{pollutant}{\emph{Pollutant name(s).}

\strong{required} | \emph{scope:} dynamic & static

The column name(s) of the pollutant(s) to plot. If multiple pollutants are
specified and a non-pairwise statistic is supplied, the \code{type} argument
will no longer be able to be used and:
\itemize{
\item \emph{Dynamic}: The pollutants can be toggled between using a "layer control" menu.
\item \emph{Static:}: The pollutants will each appear in a different panel.
}

Multiple \code{pollutants} prohibit the use of the \code{type} argument for
non-pairwise statistics.}

\item{statistic}{\emph{The statistic to be applied to each data bin in the plot}

\emph{default:} \code{"prop.mean"} | \emph{scope:} dynamic & static

Options currently include \code{"prop.count"}, \code{"prop.mean"} and \code{"abs.count"}.
\code{"prop.count"} sizes bins according to the proportion of the frequency of
measurements.  Similarly, \code{"prop.mean"} sizes bins according to their
relative contribution to the mean. \code{"abs.count"} provides the absolute
count of measurements in each bin.}

\item{breaks}{\emph{Specifier for the number of breaks of the colour axis.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic & static

Most commonly, the number of break points. If not specified, each marker
will independently break its supplied data at approximately 6 sensible
break points. When \code{breaks} are specified, all markers will use the same
break points. Breaks can also be used to set specific break points. For
example, the argument \code{breaks = c(0, 1, 10, 100)} breaks the data into
segments <1, 1-10, 10-100, >100.}

\item{latitude, longitude}{\emph{The decimal latitude(Y)/longitude(X).}

\emph{default:} \code{NULL} | \emph{scope:} dynamic & static

Column names representing the decimal latitude and longitude (or other Y/X
coordinate if using a different \code{crs}). If not provided, will be
automatically inferred from data by looking for a column named
"lat"/"latitude" or "lon"/"lng"/"long"/"longitude" (case-insensitively).}

\item{crs}{\emph{The coordinate reference system (CRS).}

\emph{default:} \code{4326} | \emph{scope:} dynamic & static

The coordinate reference system (CRS) of the data, passed to
\code{\link[sf:st_crs]{sf::st_crs()}}. By default this is \href{https://epsg.io/4326}{EPSG:4326}, the
CRS associated with the commonly used latitude and longitude coordinates.
Different coordinate systems can be specified using \code{crs} (e.g., \code{crs = 27700} for the \href{https://epsg.io/27700}{British National Grid}). Note that
non-lat/lng coordinate systems will be re-projected to EPSG:4326 for
plotting on the map.}

\item{type}{\emph{A method to condition the \code{data} for separate plotting.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic & static

Used for splitting the input data into different groups, passed to the
\code{type} argument of \code{\link[openair:cutData]{openair::cutData()}}. When \code{type} is specified:
\itemize{
\item \emph{Dynamic}: The different data splits can be toggled between using a "layer control" menu.
\item \emph{Static:}: The data splits will each appear in a different panel.
}

\code{type} cannot be used if multiple \code{pollutant} columns have been provided.}

\item{popup}{\emph{Content for marker popups on dynamic maps.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic

Columns to be used as the HTML content for marker popups on dynamic maps.
Popups may be useful to show information about the individual sites (e.g.,
site names, codes, types, etc.). If a vector of column names are provided
they are passed to \code{\link[=buildPopup]{buildPopup()}} using its default values.}

\item{label}{\emph{Content for marker hover-over on dynamic maps.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic

Column to be used as the HTML content for hover-over labels. Labels are
useful for the same reasons as popups, though are typically shorter.}

\item{provider}{\emph{The basemap(s) to be used.}

\emph{default:} \code{"OpenStreetMap"} | \emph{scope:} dynamic & static

The base map(s) to be used beneath the polar markers. If not provided, will
default to \code{"OpenStreetMap"}/\code{"osm"} for both dynamic and static maps.
\itemize{
\item \emph{Dynamic}: Any number of \link[leaflet:providers]{leaflet::providers}.
See \url{http://leaflet-extras.github.io/leaflet-providers/preview/} for a list
of all base maps that can be used. If multiple base maps are provided, they
can be toggled between using a "layer control" interface. By default, the
interface will use the provider names as labels, but users can define their
own using a named vector (e.g., \code{c("Default" = "OpenStreetMap", "Satellite"   = "Esri.WorldImagery")})
\item \emph{Static}: One of \code{\link[rosm:deprecated]{rosm::osm.types()}}.
}

There is some overlap in static and dynamic providers. For example,
\code{{ggspatial}} uses "osm" to specify "OpenStreetMap". When static providers
are provided to dynamic maps or vice versa, \code{{openairmaps}} will attempt to
substitute the correct provider string.}

\item{cols}{\emph{Colours to use for plotting.}

\emph{default:} \code{"turbo"} | \emph{scope:} dynamic & static

The colours used for plotting, passed to \code{\link[openair:openColours]{openair::openColours()}}. The
default, \code{"turbo"}, is a rainbow palette with relatively perceptually
uniform colours.}

\item{alpha}{\emph{Transparency value for polar markers.}

\emph{default:} \code{1} | \emph{scope:} dynamic & static

A value between 0 (fully transparent) and 1 (fully opaque).}

\item{key}{\emph{Draw individual marker legends?}

\emph{default:} \code{FALSE} | \emph{scope:} dynamic & static

Draw a key for each individual marker? Potentially useful when \code{limits = "free"}, but of limited use otherwise.}

\item{legend}{\emph{Draw a shared legend?}

\emph{default:} \code{TRUE} | \emph{scope:} dynamic & static

When all markers share the same colour scale (e.g., when \code{limits != "free"}
in \code{\link[=polarMap]{polarMap()}}), should a shared legend be created at the side of the map?}

\item{legend.position}{\emph{Position of the shared legend.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic & static

When \code{legend = TRUE}, where should the legend be placed?
\itemize{
\item \emph{Dynamic}: One of "topright", "topright", "bottomleft" or "bottomright". Passed to the \code{position} argument of \code{\link[leaflet:addLegend]{leaflet::addLegend()}}.
\item \emph{Static:}: One of "top", "right", "bottom" or "left". Passed to the \code{legend.position} argument of \code{\link[ggplot2:theme]{ggplot2::theme()}}.
}}

\item{legend.title}{\emph{Title of the legend.}

\emph{default:} \code{NULL} | \emph{scope:} dynamic & static

By default, when \code{legend.title = NULL}, the function will attempt to
provide a sensible legend title. \code{legend.title} allows users to overwrite
this - for example, to include units or other contextual information. For
\emph{dynamic} maps, users may wish to use HTML tags to format the title.}

\item{legend.title.autotext}{\emph{Automatically format the title of the legend?}

\emph{default:} \code{TRUE} | \emph{scope:} dynamic & static

When \code{legend.title.autotext = TRUE}, \code{legend.title} will be first run
through \code{\link[=quickTextHTML]{quickTextHTML()}} (\emph{dynamic}) or \code{\link[openair:quickText]{openair::quickText()}} (\emph{static}).}

\item{control.collapsed}{\emph{Show the layer control as a collapsed?}

\emph{default:} \code{FALSE} | \emph{scope:} dynamic

For \emph{dynamic} maps, should the "layer control" interface be collapsed? If
\code{TRUE}, users will have to hover over an icon to view the options.}

\item{control.position}{\emph{Position of the layer control menu}

\emph{default:} \code{"topright"} | \emph{scope:} dynamic

When \code{type != NULL}, or multiple pollutants are specified, where should the
"layer control" interface be placed? One of "topleft", "topright",
"bottomleft" or "bottomright". Passed to the \code{position} argument of
\code{\link[leaflet:addLayersControl]{leaflet::addLayersControl()}}.}

\item{control.autotext}{\emph{Automatically format the content of the layer
control menu?}

\emph{default:} \code{TRUE} | \emph{scope:} dynamic

When \code{control.autotext = TRUE}, the content of the "layer control"
interface will be first run through \code{\link[=quickTextHTML]{quickTextHTML()}}.}

\item{d.icon}{\emph{The diameter of the plot on the map in pixels.}

\emph{default:} \code{200} | \emph{scope:} dynamic & static

This will affect the size of the individual polar markers. Alternatively, a
vector in the form \code{c(width, height)} can be provided if a non-circular
marker is desired.}

\item{d.fig}{\emph{The diameter of the plots to be produced using \code{{openair}} in
inches.}

\emph{default:} \code{3.5} | \emph{scope:} dynamic & static

This will affect the resolution of the markers on the map. Alternatively, a
vector in the form \code{c(width, height)} can be provided if a non-circular
marker is desired.}

\item{static}{\emph{Produce a static map?}

\emph{default:} \code{FALSE}

This controls whether a \emph{dynamic} or \emph{static} map is produced. The former
is the default and is broadly more useful, but the latter may be preferable
for DOCX or PDF outputs (e.g., academic papers).}

\item{static.nrow}{\emph{Number of rows in a static map.}

\emph{default:} \code{NULL} | \emph{scope:} static

Controls the number of rows of panels on a static map when multiple
\code{pollutant}s or \code{type} are specified; passed to the \code{nrow} argument of
\code{\link[ggplot2:facet_wrap]{ggplot2::facet_wrap()}}. The default, \code{NULL}, results in a roughly square
grid of panels.}

\item{progress}{\emph{Show a progress bar?}

\emph{default:} \code{TRUE} | \emph{scope:} dynamic & static

By default, a progress bar is shown to visualise the function's progress
creating individual polar markers. This option allows this to be turned
off, if desired.}

\item{n.core}{\emph{Number of cores to use in parallel processing.}

\emph{default:} \code{1L} | \emph{scope:} dynamic & static

By default, each polar marker is drawn and saved sequentially. For big maps
with a lot of markers, this can be slow. Adjusting \code{n.core} to a number
greater than \code{1} will use \link[mirai:mirai-package]{mirai} to create markers
in parallel.}

\item{...}{
  Arguments passed on to \code{\link[openair:pollutionRose]{openair::pollutionRose}}
  \describe{
    \item{\code{key.footer}}{Adds additional text/labels below the scale key. See
\code{key.header} for further information.}
    \item{\code{key.position}}{Location where the scale key is to plotted. Allowed
arguments currently include \dQuote{top}, \dQuote{right}, \dQuote{bottom}
and \dQuote{left}.}
    \item{\code{paddle}}{Either \code{TRUE} or \code{FALSE}. If \code{TRUE} plots rose
using 'paddle' style spokes. If \code{FALSE} plots rose using 'wedge' style
spokes.}
    \item{\code{seg}}{When \code{paddle = TRUE}, \code{seg} determines with width of the
segments. For example, \code{seg = 0.5} will produce segments 0.5 *
\code{angle}.}
    \item{\code{normalise}}{If \code{TRUE} each wind direction segment is normalised to
equal one. This is useful for showing how the concentrations (or other
parameters) contribute to each wind sector when the proportion of time the
wind is from that direction is low. A line showing the probability that the
wind directions is from a particular wind sector is also shown.}
  }}

\item{control}{\strong{Deprecated.} Please use \code{type}.}
}
\value{
Either:
\itemize{
\item \emph{Dynamic:} A leaflet object
\item \emph{Static:} A \code{ggplot2} object using \code{\link[ggplot2:ggsf]{ggplot2::coord_sf()}} coordinates with a \code{ggspatial} basemap
}
}
\description{
The \code{\link[=pollroseMap]{pollroseMap()}} function creates a map using pollution roses as markers.
Any number of pollutants can be specified using the \code{pollutant} argument, and
multiple layers of markers can be created using \code{type}. By default, these
maps are dynamic and can be panned, zoomed, and otherwise interacted with.
Using the \code{static} argument allows for static images to be produced instead.
}
\section{Customisation of static maps using ggplot2}{


As the outputs of the static directional analysis functions are \code{ggplot2}
figures, further customisation is possible using functions such as
\code{\link[ggplot2:theme]{ggplot2::theme()}}, \code{\link[ggplot2:guides]{ggplot2::guides()}} and \code{\link[ggplot2:labs]{ggplot2::labs()}}.

If multiple pollutants are specified, subscripting (e.g., the "x" in "NOx")
is achieved using the \link[ggtext:ggtext]{ggtext} package. Therefore if you
choose to override the plot theme, it is recommended to use
\verb{[ggplot2::theme()]} and \verb{[ggtext::element_markdown()]} to define the
\code{strip.text} parameter.

When arguments like \code{limits}, \code{percentile} or \code{breaks} are defined, a
legend is automatically added to the figure. Legends can be removed using
\code{ggplot2::theme(legend.position = "none")}, or further customised using
\code{\link[ggplot2:guides]{ggplot2::guides()}} and either \code{color = ggplot2::guide_colourbar()} for
continuous legends or \code{color = ggplot2::guide_legend()} for discrete
legends.
}

\examples{
\dontrun{
pollroseMap(polar_data,
  pollutant = "nox",
  statistic = "prop.count",
  provider = "CartoDB.Voyager"
)
}
}
\seealso{
\code{\link[openair:pollutionRose]{openair::pollutionRose()}}

Other directional analysis maps: 
\code{\link{annulusMap}()},
\code{\link{diffMap}()},
\code{\link{freqMap}()},
\code{\link{percentileMap}()},
\code{\link{polarMap}()},
\code{\link{windroseMap}()}
}
\concept{directional analysis maps}
