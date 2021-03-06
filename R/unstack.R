#' Unstack "stacks" in Snow's cholera map.
#'
#' Unstacks fatalities data by 1) assigning the coordinates of the base case to all cases in a stack and 2) setting the base case as an "address" and making the number of fatalities an attribute.
#' @param multi.core Logical or Numeric. \code{TRUE} uses \code{parallel::detectCores()}. \code{FALSE} uses one, single core. With Numeric, you specify the number logical cores. On Windows, only \code{multi.core = FALSE} is available.
#' @param fatalities Corrected fatalities data from \code{cholera::fixFatalities()}. For original data, use \code{HistData::Snow.deaths}.
#' @param compute Logical. \code{TRUE} computes data. \code{FALSE} uses pre-computed data.
#' @seealso \code{vignette("unstacking.fatalities")}
#' @return An R list that includes \code{anchor.case}, \code{fatalities.address}, \code{fatalities.unstacked} and \code{ortho.proj}.
#' @section Notes: This function is computationally intensive. On a 2.3 GHz Intel Core i7 with R version 3.5.2, it takes approximately 195 seconds to run on one core and approximately 47 seconds to run on eight logical (four physical) cores. These functions document the code that generates \code{\link{anchor.case}}, \code{\link{fatalities.address}}, \code{\link{fatalities.unstacked}} and \code{\link{ortho.proj}}.
#' @export

unstackFatalities <- function(multi.core = FALSE, compute = FALSE,
  fatalities = fixFatalities()) {

  if (compute) {
    cores <- multiCore(multi.core)
    rd <- cholera::roads[cholera::roads$street %in% cholera::border == FALSE, ]
    map.frame <- cholera::roads[cholera::roads$street %in% cholera::border, ]
    roads.list <- split(rd[, c("x", "y")], rd$street)
    border.list <- split(map.frame[, c("x", "y")], map.frame$street)

    case.id <- fatalities$case

    orthogonal.projection <- parallel::mclapply(case.id, function(case) {
      case.data <- fatalities[fatalities$case == case, c("x", "y")]

      within.radius <- lapply(cholera::road.segments$id, function(id) {
        seg.data <- cholera::road.segments[cholera::road.segments$id == id, ]
        test1 <- withinRadius(case.data, seg.data[, c("x1", "y1")])
        test2 <- withinRadius(case.data, seg.data[, c("x2", "y2")])
        if (any(test1, test2)) unique(seg.data$id)
      })

      within.radius <- unlist(within.radius)

      ortho.proj.test <- lapply(within.radius, function(seg.id) {
        ortho.data <- orthogonalProjection(case, seg.id)
        x.proj <- ortho.data$x.proj
        y.proj <- ortho.data$y.proj

        seg.data <- cholera::road.segments[cholera::road.segments$id == seg.id,
          c("x1", "y1", "x2", "y2")]

        seg.df <- data.frame(x = c(seg.data$x1, seg.data$x2),
                             y = c(seg.data$y1, seg.data$y2))

        # segment bisection/intersection test
        distB <- stats::dist(rbind(seg.df[1, ], c(x.proj, y.proj))) +
                 stats::dist(rbind(seg.df[2, ], c(x.proj, y.proj)))

        bisect.test <- signif(stats::dist(seg.df)) == signif(distB)

        if (bisect.test) {
          dat <- rbind(c(case.data$x, case.data$y), c(x.proj, y.proj))
          ortho.dist <- c(stats::dist(dat))
          ortho.pts <- data.frame(x.proj, y.proj)
          data.frame(road.segment = seg.id, ortho.pts, ortho.dist,
            stringsAsFactors = FALSE)
        } else {
          null.out <- data.frame(matrix(NA, ncol = 4))
          names(null.out) <- c("road.segment", "x.proj", "y.proj", "ortho.dist")
          null.out
        }
      })

      out <- do.call(rbind, ortho.proj.test)

      if (all(is.na(out)) == FALSE) {
        sel <- which.min(out$ortho.dist)
        out[sel, ]
      } else {
        out[1, ] # all candidate roads are NA; arbitrarily choose first obs.
      }
    }, mc.cores = cores)

    ortho.proj <- do.call(rbind, orthogonal.projection)
    row.names(ortho.proj) <- NULL
    ortho.proj$case <- case.id

    road.segment.fix <- list(
      "216-1" = c(290, 61, 174, 547, 523, 521, 138, 59, 340, 508),
      "290-1" = c(409, 131, 18, 575, 566, 518, 297),
      "259-1" = 145,
      "231-1" = c(329, 248, 408, 471),
      "340-2" = c(172, 62, 111),
      "128-1" = 302,
      "141-1" = 163,
      "169-1" = 516,
      "188-1" = 372,
      "222-1" = 520,
      "237-1" = 308,
      "330-1" = 453,
      "207-1" = 277,
      "196-1" = 346,
      "186-1" = 278,
      "261-1" = 69,
      "270-1" = 267,
      "159-1" = 165,
      "193-1" = c(463, 423),
      "216-1" = c(122, 91),
      "203-1" = 287,
      "259-2" = c(303, 513, 405, 175),
      "297-1" = 117,
      "224-1" = c(355, 253),
      "234-1" = c(254, 367, 492, 406),
      "193-1" = c(180, 452, 551),
      "178-1" = 85,
      "231-1" = 341,
      "160-3" = 558,
      "269-1" = 462,
      "326-2" = 483)

    # Recompute orthogonal distances

    ortho.projB <- parallel::mclapply(seq_along(road.segment.fix), function(i) {
      case.data <- fatalities[unlist(road.segment.fix[[i]]), ]
      seg.id <- names(road.segment.fix[i])

      ortho.data <- lapply(case.data$case, function(x) {
        orthogonalProjection(x, seg.id)
      })

      ortho.data <- do.call(rbind, ortho.data)
      x.proj <- ortho.data$x.proj
      y.proj <- ortho.data$y.proj

      proj.data <- lapply(1:nrow(case.data), function(j) {
        dat <- rbind(case.data[j, c("x", "y")], c(x.proj[j], y.proj[j]))
        cbind(x.proj[j], y.proj[j], c(stats::dist(dat)))
      })

      out <- data.frame(seg.id, do.call(rbind, proj.data), case.data$case,
        stringsAsFactors = FALSE)
      names(out) <- c("road.segment", "x.proj", "y.proj", "ortho.dist", "case")
      out
    }, mc.cores = cores)

    ortho.projB <- do.call(rbind, ortho.projB)
    row.names(ortho.projB) <- NULL

    ## Manual fix: endpoint cases ##

    ## Portland Mews: 286, 558 ##

    #       56
    # 558  286  anchor
    # --------

    old.st <- "160-2"
    new.st <- "160-3"

    case.select <- 286
    case <- fatalities[case.select, ]
    x.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "x2"]
    y.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "y2"]
    ortho.dist <- stats::dist(rbind(case[, c("x", "y")], c(x.proj, y.proj)))
    data.fix <- data.frame(road.segment = new.st, x.proj, y.proj,
      ortho.dist = c(ortho.dist), case = case.select)

    ortho.projB <- rbind(ortho.projB, data.fix)

    case.select <- 56
    case <- fatalities[case.select, ]
    x.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "x2"]
    y.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "y2"]
    ortho.dist <- stats::dist(rbind(case[, c("x", "y")], c(x.proj, y.proj)))
    data.fix <- data.frame(road.segment = new.st, x.proj, y.proj,
      ortho.dist = c(ortho.dist), case = case.select)

    ortho.projB <- rbind(ortho.projB, data.fix)

    ## William and Mary Yard: 440 ##
    # ortho.proj[ortho.proj$case == 440, ]

    # 259-2: |
    # 259-1:  _

    old.st <- "317-3"
    new.st <- "259-1"

    case.select <- 440
    case <- fatalities[case.select, ]
    x.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "x2"]
    y.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "y2"]
    ortho.dist <- stats::dist(rbind(case[, c("x", "y")], c(x.proj, y.proj)))
    data.fix <- data.frame(road.segment = new.st, x.proj, y.proj,
      ortho.dist = c(ortho.dist), case = case.select)

    ortho.projB <- rbind(ortho.projB, data.fix)

    ## St James Workhouse: [369] 434, 11, 53, 193 ##
    # move anchor 369 and associated cases to endpoint of St James Workhouse
    # segment

    old.st <- "194-1"
    new.st <- "148-1"

    case.select <- c(369, 434, 11, 53, 193)
    case <- fatalities[fatalities$case %in% case.select, ]
    x.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "x1"]
    y.proj <- cholera::road.segments[cholera::road.segments$id == new.st, "y1"]

    ortho.dist <- vapply(case$case, function(x) {
      stats::dist(rbind(case[case$case == x, c("x", "y")], c(x.proj, y.proj)))
    }, numeric(1L))

    data.fix <- data.frame(road.segment = new.st, x.proj, y.proj,
      ortho.dist = ortho.dist, case = case$case)

    ortho.projB <- rbind(ortho.projB, data.fix)

    ## Re-assemble ##

    ortho.proj[ortho.proj$case %in% ortho.projB$case, ] <- ortho.projB
    ortho.proj <- ortho.proj[order(ortho.proj$case), ]
    row.names(ortho.proj) <- NULL

    ## Single and Multiple ##

    road.incidence <- table(ortho.proj$road.segment)
    road.incidence <- data.frame(id = names(road.incidence),
      count = c(road.incidence), stringsAsFactors = FALSE)
    row.names(road.incidence) <- NULL

    single.obs <- road.incidence[road.incidence$count == 1, ]
    single.address <- lapply(single.obs$id, function(i) {
      data.frame(id = i, case = ortho.proj[ortho.proj$road.segment == i,
        "case"])
    })

    cutpoint <- 0.05
    multiple.obs <- road.incidence[road.incidence$count > 1, ]

    multiple.address <- parallel::mclapply(multiple.obs$id, function(i) {
      cases <- ortho.proj[ortho.proj$road.segment == i, "case"]
      ortho <- ortho.proj[ortho.proj$road.segment == i, c("x.proj", "y.proj")]
      orientation <- sign(fatalities[cases, c("x", "y")] - ortho)

      sideA <- (orientation$x == -1 & orientation$y == 1) |
        (orientation$x == -1 & orientation$y == -1) |
        (orientation$x == 0 & orientation$y == 1) |
        (orientation$x == 1 & orientation$y == 0)

      orientation$side <- ifelse(sideA, 1, 0)

      if (length(unique(orientation$side)) == 2) {
        A <- as.numeric(row.names(orientation[orientation$side == 1, ]))
        B <- as.numeric(row.names(orientation[orientation$side == 0, ]))
        dataA <- ortho.proj[ortho.proj$case %in% A, c("x.proj", "y.proj")]
        dataB <- ortho.proj[ortho.proj$case %in% B, c("x.proj", "y.proj")]

        if (nrow(dataA) >= 2) {
          clusterA <- stats::hclust(stats::dist(dataA))
          outA <- stats::cutree(clusterA, h = cutpoint)
        } else {
          outA <- 1
          names(outA) <- row.names(dataA)
        }

        if (nrow(dataB) >= 2) {
          clusterB <- stats::hclust(stats::dist(dataB))
          outB <- stats::cutree(clusterB, h = cutpoint)
        } else {
          outB <- 1
          names(outB) <- row.names(dataB)
        }

        outB <- max(outA) +  outB
        census <- c(outA, outB)
        out <- data.frame(case = as.numeric(names(census)), group = census,
          stringsAsFactors = FALSE)
        row.names(out) <- NULL
      }

      if (length(unique(orientation$side)) == 1) {
        A <- as.numeric(row.names(orientation))
        dataA <- ortho.proj[ortho.proj$case %in% A, c("x.proj", "y.proj")]

        if (nrow(dataA) >= 2) {
          clusterA <- stats::hclust(stats::dist(dataA))
          outA <- stats::cutree(clusterA, h = cutpoint)
        } else {
          outA <- 1
        }

        out <- data.frame(case = A, group = outA, stringsAsFactors = FALSE)
        row.names(out) <- NULL
      }

      out <- merge(out, ortho.proj[ortho.proj$road.segment == i,
        c("case", "ortho.dist")], by = "case")
      out <- out[order(out$group, out$ortho.dist), ]
      out$anchor <- ifelse(duplicated(out$group) == FALSE, 1, 0)
      data.frame(id = i, out, stringsAsFactors = FALSE)
    }, mc.cores = cores)

    multiple.unstacked <- parallel::mclapply(multiple.address, function(x) {
      group.id <- unique(x$group)
      group.data <- lapply(group.id, function(i) {
        tmp <- x[x$group == i, ]
        tmp$case.count <- nrow(tmp)
        tmp$anchor <- tmp[tmp$anchor == 1, "case"]
        tmp$ortho.dist <- NULL
        tmp
      })
      do.call(rbind, group.data)
    })

    multiple.unstacked <- do.call(rbind,multiple.unstacked)
    multiple.unstacked$multiple.obs.seg <- "Yes"

    single.unstacked <- do.call(rbind, single.address)
    single.unstacked[ c("group", "anchor",  "case.count")] <- 1
    single.unstacked$anchor <- single.unstacked$case
    single.unstacked$multiple.obs.seg <- "No"

    unstacked <- rbind(multiple.unstacked, single.unstacked)
    unstacked <- merge(unstacked, fatalities, by.x = "anchor", by.y = "case")

    fatalities.unstacked <- unstacked[, c("case", "x", "y")]
    fatalities.unstacked <-
      fatalities.unstacked[order(fatalities.unstacked$case), ]
    row.names(fatalities.unstacked) <- NULL

    vars <- c("case", "x", "y", "case.count")
    fatalities.address <- unstacked[unstacked$anchor == 1, vars]
    names(fatalities.address)[1] <- "anchor"

    anchor.case <- unstacked[, c("anchor", "case")]

    list(anchor.case = anchor.case,
         fatalities.unstacked = fatalities.unstacked,
         fatalities.address = fatalities.address,
         ortho.proj = ortho.proj)

  } else {
    list(anchor.case = cholera::anchor.case,
        fatalities.address = cholera::fatalities.address,
        fatalities.unstacked = cholera::fatalities.unstacked,
        ortho.proj = cholera::ortho.proj)
  }
}
