% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/distanceTime.R
\name{distanceTime}
\alias{distanceTime}
\title{Convert distance to elapsed time.}
\usage{
distanceTime(x, distance.unit = "meter", time.unit = "second",
  walking.speed = 5)
}
\arguments{
\item{x}{Numeric. Nominal map distance.}

\item{distance.unit}{Character. Unit of distance: "meter", "yard" or "native". "native" returns the map's native scale. See \code{vignette("roads")} for information on conversion.}

\item{time.unit}{Character. Unit of measurement: "hour", "minute" or "second".}

\item{walking.speed}{Numeric. Walking speed in km/hr.}
}
\value{
An R vector.
}
\description{
Convert distance to elapsed time.
}
