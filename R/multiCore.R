#' Set or compute the number of cores for parallel::mclapply().
#'
#' @param x Logical or Numeric. TRUE uses parallel::detectCores(). FALSE uses one, single core. Or, you can also specify the number of logical cores to use.
#' @noRd

multiCore <- function(x) {
  if (is.logical(x)) {
    if (x) {
      cores <- parallel::detectCores()
    } else {
      if (is.numeric(x)) {
        if (is.integer(x)) {
          cores <- x
        } else {
          cores <- as.integer(x)
        }
      } else {
        cores <- 1L
      }
    }
  } else if (is.numeric(x)) {
    obs.cores <- parallel::detectCores()
    if (x > obs.cores) {
      stop(paste0('For your system, "cores" must be <= ', obs.cores, "."))
    }
    if (is.integer(x)) {
      cores <- x
    } else {
      cores <- as.integer(x)
    }
  }
  cores
}