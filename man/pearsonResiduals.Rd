% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pearsonResiduals.R
\name{pearsonResiduals}
\alias{pearsonResiduals}
\title{Compute Pearson Residuals (prototype)}
\usage{
pearsonResiduals(x)
}
\arguments{
\item{x}{An object created by \code{neighborhoodEuclidean()}, \code{neighborhoodVoronoi()} or \code{neighborhoodWalking()}.}
}
\value{
An R vector.
}
\description{
Compute Pearson Residuals (prototype)
}
\examples{
\dontrun{

pearsonResiduals(neighborhoodEuclidean())
pearsonResiduals(neighborhoodVoronoi())
pearsonResiduals(neighborhoodWalking())
}
}
