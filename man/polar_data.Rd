% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{polar_data}
\alias{polar_data}
\title{Example data for polar mapping functions}
\format{
An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 35040 rows and 13 columns.
}
\source{
\code{polar_data} was compiled from data using the
\code{\link[openair:importUKAQ-wrapper]{openair::importAURN()}} function from the \code{openair} package with
meteorological data from the \code{worldmet} package.
}
\usage{
polar_data
}
\description{
The \code{polar_data} dataset is provided as an example dataset as part of
the \code{openairmaps} package. The dataset contains hourly measurements of
air pollutant concentrations, location and meteorological data.
}
\details{
\describe{
\item{date}{The date and time of the measurement}
\item{nox, no2, pm2.5, pm10}{Pollutant concentrations}
\item{site}{The site name. Useful for use with the \code{popup} and \code{label} arguments in \code{openairmaps} functions.}
\item{latitude, longitude}{Decimal latitude and longitude of the sites.}
\item{site.type}{Site type of the site (either "Urban Traffic" or "Urban Background").}
\item{wd}{Wind direction, in degrees from North, as a numeric vector.}
\item{ws}{Wind speed, in m/s, as numeric vector.}
\item{visibility}{The visibility in metres.}
\item{air_temp}{Air temperature in degrees Celcius.}
}
}
\examples{
polar_data
}
\keyword{datasets}
