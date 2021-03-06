% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nearestPump.R
\name{nearestPump}
\alias{nearestPump}
\title{Compute shortest distances or paths to selected pumps.}
\usage{
nearestPump(pump.select = NULL, metric = "walking",
  output = "distance", vestry = FALSE, weighted = TRUE,
  case.set = "observed", distance.unit = "meter", multi.core = FALSE,
  time.unit = "second", walking.speed = 5)
}
\arguments{
\item{pump.select}{Numeric. Pump candidates to consider. Default is \code{NULL}: all pumps are used. Otherwise, selection by a vector of numeric IDs: 1 to 13 for \code{pumps}; 1 to 14 for \code{pumps.vestry}. Negative selection allowed.}

\item{metric}{Character. "eucldidean" or "walking".}

\item{output}{Character. "distance" or "path".}

\item{vestry}{Logical. \code{TRUE} uses the 14 pumps from the Vestry Report. \code{FALSE} uses the 13 in the original map.}

\item{weighted}{Logical. \code{TRUE} computes shortest path in terms of road length. \code{FALSE} computes shortest path in terms of the number of nodes.}

\item{case.set}{Character. "observed", "expected", or "snow".}

\item{distance.unit}{Character. Unit of distance: "meter", "yard" or "native". "native" returns the map's native scale. Meaningful only when "weighted" is \code{TRUE} and "output" is "distance". See \code{vignette("roads")} for information on unit distances.}

\item{multi.core}{Logical or Numeric. \code{TRUE} uses \code{parallel::detectCores()}. \code{FALSE} uses one, single core. You can also specify the number logical cores. On Windows, only \code{multi.core = FALSE} is available.}

\item{time.unit}{Character. "hour", "minute", or "second".}

\item{walking.speed}{Numeric. Walking speed in km/hr.}
}
\value{
An R data frame or list of 'igraph' paths.
}
\description{
Compute shortest distances or paths to selected pumps.
}
\note{
Time is computed using \code{distanceTime()}.
}
