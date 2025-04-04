% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/network_networkMap.R
\name{networkMap}
\alias{networkMap}
\title{Create a leaflet map of air quality measurement network sites}
\usage{
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
}
\arguments{
\item{source}{\emph{One or more UK or European monitoring networks.}

\emph{default:} \code{"aurn"}

One or more air quality networks for which data is available through
openair. Available networks include:
\itemize{
\item \code{"aurn"}, The UK Automatic Urban and Rural Network.
\item \code{"aqe"}, The Air Quality England Network.
\item \code{"saqn"}, The Scottish Air Quality Network.
\item \code{"waqn"}, The Welsh Air Quality Network.
\item \code{"ni"}, The Northern Ireland Air Quality Network.
\item \code{"local"}, Locally managed air quality networks in England.
\item \code{"imperial"}, Imperial College London (formerly King's College London) networks.
\item \code{"europe"}, European AirBase/e-reporting data.
}

There are two additional options provided for convenience:
\itemize{
\item \code{"ukaq"} will return metadata for all networks for which data is imported by importUKAQ() (i.e., AURN, AQE, SAQN, WAQN, NI, and the local networks).
\item \code{"all"} will import all available metadata (i.e., "ukaq" plus "kcl" and "europe").
}}

\item{control}{\emph{Option to create a 'layer control' menu.}

\emph{default}: \code{NULL}

A string to specify categories in a "layer control" menu, to allow readers
to select between different site categories. Choices include:
\itemize{
\item \code{"variable"} to toggle between different pollutants
\item \code{"site_type"} for different site classifications
\item \code{"agglomeration"}, \code{"zone"} or \code{"local_authority"} for different regions of the UK
\item \code{"network"} for different monitoring networks, if more than one \code{source} is provided.
}}

\item{year}{\emph{A year, or range of years, with which to filter data.}

\emph{default}: \code{NULL}

By default, \code{\link[=networkMap]{networkMap()}} visualises sites which are currently
operational. \code{year} allows users to show sites open in a specific year, or
over a range of years. See \code{\link[openair:importMeta]{openair::importMeta()}} for more information.}

\item{cluster}{\emph{Cluster markers together when zoomed out?}

\emph{default:} \code{TRUE}

When \code{cluster = TRUE}, markers are clustered together. This may be useful
for sources like \code{"imperial"} where there are many markers very close
together. Defaults to \code{TRUE}, and is forced to be \code{TRUE} when \code{source = "europe"} due to the large number of sites.}

\item{provider}{\emph{The basemap(s) to be used.}

\emph{default:} \code{c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")}

Any number of \link[leaflet:providers]{leaflet::providers}. See
\url{http://leaflet-extras.github.io/leaflet-providers/preview/} for a list of
all base maps that can be used. If multiple base maps are provided, they
can be toggled between using a "layer control" interface. By default, the
interface will use the provider names as labels, but users can define their
own using a named vector (e.g., \code{c("Default" = "OpenStreetMap", "Satellite" = "Esri.WorldImagery")})}

\item{legend}{\emph{Draw a shared legend?}

\emph{default:} \code{TRUE}

When multiple \code{source}s are defined, should a shared legend be created at
the side of the map?}

\item{legend.position}{\emph{Position of the legend}

\emph{default:} \code{"topright"}

Where should the shared legend be placed? One of "topleft", "topright",
"bottomleft" or "bottomright". Passed to the \code{position} argument of
\code{\link[leaflet:addLayersControl]{leaflet::addLayersControl()}}.}

\item{control.collapsed}{\emph{Show the layer control as a collapsed?}

\emph{default:} \code{FALSE}

Should the "layer control" interface be collapsed? If \code{TRUE}, users will
have to hover over an icon to view the options.}

\item{control.position}{\emph{Position of the layer control menu}

\emph{default:} \code{"topright"}

Where should the "layer control" interface be placed? One of "topleft",
"topright", "bottomleft" or "bottomright". Passed to the \code{position}
argument of \code{\link[leaflet:addLayersControl]{leaflet::addLayersControl()}}.}
}
\value{
A leaflet object.
}
\description{
This function uses \code{\link[openair:importMeta]{openair::importMeta()}} to obtain metadata for measurement
sites and uses it to create an attractive \code{leaflet} map. By default a map
will be created in which readers may toggle between a vector base map and a
satellite/aerial image, although users can further customise the control menu
using the \code{provider} and \code{control} parameters.
}
\details{
When selecting multiple data sources using \code{source}, please be mindful that
there can be overlap between the different networks. For example, an air
quality site in Scotland may be part of the AURN \emph{and} the SAQN.
\code{\link[=networkMap]{networkMap()}} will only show one marker for such sites, and uses the order
in which \code{source} arguments are provided as the hierarchy by which to assign
sites to networks. The aforementioned AURN & SAQN site will therefore have
its SAQN code displayed if \code{source = c("saqn", "aurn")}, and its AURN code
displayed if \code{source = c("aurn", "saqn")}.

This hierarchy is also reflected when \code{control = "network"} is used. As
\code{leaflet} markers cannot be part of multiple groups, the AURN & SAQN site
will be part of the "SAQN" layer control group when \code{source = c("saqn", "aurn")} and the "AURN" layer control group when \code{source = c("aurn", "saqn")}.
}
\examples{
\dontrun{
# view one network, grouped by site type
networkMap(source = "aurn", control = "site_type")

# view multiple networks, grouped by network
networkMap(source = c("aurn", "waqn", "saqn"), control = "network")
}

}
\seealso{
Other uk air quality network mapping functions: 
\code{\link{searchNetwork}()}
}
\concept{uk air quality network mapping functions}
