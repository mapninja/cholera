% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/unstack.R
\name{unstackFatalities}
\alias{unstackFatalities}
\title{Unstack "stacks" in Snow's cholera map.}
\usage{
unstackFatalities(multi.core = FALSE, compute = FALSE,
  fatalities = cholera::fixFatalities())
}
\arguments{
\item{multi.core}{Logical or Numeric. TRUE uses parallel::detectCores(). FALSE uses one, single core. With Numeric, you specify the number logical cores (rounds with as.integer()). On Windows, only "multi.core = FALSE" is available.}

\item{compute}{Logical. TRUE computes data. FALSE uses pre-computed data.}

\item{fatalities}{Corrected fatalies data from cholera::fixFatalities(). For original data, use HistData::Snow.deaths.}
}
\value{
An R list that includes anchor.case, fatalities.address, fatalities.unstacked and ortho.proj.
}
\description{
Unstacks fatalities data by 1) assigning the coordinates of the base case to all cases in a stack and 2) setting the base case as an "address" and making the number of fatalities an attribute.
}
\section{Notes}{
 This function is computationally intensive. On a 2.3 GHz Intel Core i7, it takes approximately 5 minutes on one core and approximately 70 seconds with eight logical (four physical) cores. This function documents the code that generates the pre-computed data included in this package.
}
