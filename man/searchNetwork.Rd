% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/network_searchNetwork.R
\name{searchNetwork}
\alias{searchNetwork}
\title{Geographically search the air quality networks made available by
\code{\link[openair:importMeta]{openair::importMeta()}}}
\usage{
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
}
\arguments{
\item{lat, lng}{\emph{The decimal latitude(Y)/longitude(X).}

\strong{required}

Values representing the decimal latitude and longitude (or other Y/X
coordinate if using a different \code{crs}) of the site of interest.}

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

\item{year}{\emph{A year, or range of years, with which to filter data.}

\emph{default}: \code{NULL}

By default, \code{\link[=networkMap]{networkMap()}} visualises sites which are currently
operational. \code{year} allows users to show sites open in a specific year, or
over a range of years. See \code{\link[openair:importMeta]{openair::importMeta()}} for more information.}

\item{site_type}{\emph{One or more site types with which to subset the site
metadata.}

\emph{default:} \code{NULL}

If \code{site_type} is specified, only sites of that type will be searched for.
For example, \code{site_type = "urban background"} will only search urban
background sites.}

\item{variable}{\emph{One or more variables of interest with which to subset the
site metadata.}

\emph{default:} \code{NULL}

If \code{variable} is specified, only sites measuring at least one of these
pollutants will be searched for. For example, \code{variable = c("pm10", "co")}
will search sites that measure PM10 and/or CO.}

\item{max_dist}{\emph{A maximum distance from the location of interest in
kilometres.}

\emph{default:} \code{NULL}

If \code{max_dist} is specified, only sites within \code{max_dist} kilometres from
the \code{lat} / \code{lng} coordinate will be searched for.}

\item{n}{\emph{The maximum number of sites to return.}

\emph{default:} \code{NULL}

If \code{n} is specified, only \code{n} sites will be returned. Note that this
filtering step is applied last, after \code{site_type}, \code{variable}, and
\code{max_dist}.}

\item{crs}{\emph{The coordinate reference system (CRS).}

\emph{default:} \code{4326} | \emph{scope:} dynamic & static

The coordinate reference system (CRS) of the data, passed to
\code{\link[sf:st_crs]{sf::st_crs()}}. By default this is \href{https://epsg.io/4326}{EPSG:4326}, the
CRS associated with the commonly used latitude and longitude coordinates.
Different coordinate systems can be specified using \code{crs} (e.g., \code{crs = 27700} for the \href{https://epsg.io/27700}{British National Grid}). Note that
non-lat/lng coordinate systems will be re-projected to EPSG:4326 for
plotting on the map.}

\item{map}{\emph{Return a map?}

\emph{default:} \code{TRUE}

If \code{TRUE}, the default, \code{\link[=searchNetwork]{searchNetwork()}} will return a \code{leaflet} map. If
\code{FALSE}, it will instead return a \link[tibble:tibble-package]{tibble}.}
}
\value{
Either a \link[tibble:tibble-package]{tibble} or \code{leaflet} map.
}
\description{
While \code{\link[=networkMap]{networkMap()}} visualises entire UK air quality networks,
\code{\link[=searchNetwork]{searchNetwork()}} can subset specific networks to find air quality sites near
to a specific site of interest (for example, the location of known industrial
activity, or the centroid of a specific urban area).
}
\details{
Data subsetting progresses in the order in which the arguments are given;
first \code{source} and \code{year}, then \code{site_type} and \code{variable}, then \code{max_dist},
and finally \code{n}.
}
\examples{
\dontrun{
# get all AURN sites open in 2020 within 20 km of Buckingham Palace
palace <- convertPostcode("SW1A1AA")
searchNetwork(lat = palace$lat, lng = palace$lng, max_dist = 20, year = 2020)
}
}
\seealso{
Other uk air quality network mapping functions: 
\code{\link{networkMap}()}
}
\concept{uk air quality network mapping functions}
