note on duplicate and missing cases
================
lindbrook
2019-02-07

## Duplicate Cases: Cambridge Street

The three pairs of case with duplicate coordinates lie at two different
locations on opposite sides of Cambridge Street (91 and 241; 209 and
429; 93 and
214):

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-2-1.png" style="display: block; margin: auto auto auto 0;" />

## Missing Cases: Broad Street

Two of the “missing” cases are located at 40 Broad Street, which lies
just southwest (below and to the left) of the Broad Street Pump.

While Snow’s map shows four “bars” or cases,

![](broad.street.A.png)

Dodson and Tobler’s data show only two, cases 32 and 122. Furthermore,
the two cases also appear to be farther apart than is seen in nearby
stacks:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-3-1.png" style="display: block; margin: auto auto auto 0;" />

## Missing Case: Noel Street

The third “missing” case is located at 15 Noel Street, which lies north
of Broad Street one block south of Oxford Street at the intersection
with Berwick Street.

Snow’s map shows three cases at the end of Noel Street:

![](noel.street.png)

But Dodson and Tobler’s data shows only two: 282 and 422. Like the cases
on Broad Street, the pair also appears to be farther apart than what is
seen in nearby
stacks:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-4-1.png" style="display: block; margin: auto auto auto 0;" />

## A Solution

One solution to these problems is to use the three duplicate
observations from Cambridge Street to fill in for the three “missing”
observations on Broad and Noel Streets. This is both plausible and
reasonable.

What makes it plausible is that with the exception of the x-y
coordinates of the case at the base of a stack, the remaining
coordinates, which make up 44% (257/578) of all bars and which include
the proposed locations for the three “missing” observations, do not
represent the location of cases. They only serve to align bars within a
stack. For this reason, there should be no objections to moving this
class of bars.

What makes it reasonable is that I do not relocate bars by hand.
Instead, I use simple geometric interpolation: I use the existing
observations in a stack to determine the “standard” *unit* distance
between bars and then use multiples of that *unit* distance to position
the “missing” observations.

Consider 40 Broad Street. On Snow’s map, there are four cases but on
Dodson and Tobler’s there are just two. Visual inspection leads me to
make three claims: 1) the distance between the two observed cases, 32
and 122, is greater than that at neighboring stacks; 2) there appears to
be room for one “missing” case between 32 and 122; and 3) the other
“missing” case could be located just beyond case 122.

The proposed coordinates are illustrated
below:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-6-1.png" style="display: block; margin: auto auto auto 0;" />

## Geometric interpolation: *unit* distance

To explain how I arrived at these coordinates, I use 40 Broad Street as
an example to illustrate the computation of the *unit* distance in one
dimension and then move on to the computation of the two dimensional
case. Note that I rotate the data so that the stack lies along a single
(horizontal) dimension. To fit one “missing” case between cases 32 and
122, I set the *unit* distance between the two observed cases to
2:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-7-1.png" style="display: block; margin: auto auto auto 0;" />

I then place one “missing” case 1 *unit* away from
32:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto auto auto 0;" />

And place the other “missing” case three *units*
away:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-9-1.png" style="display: block; margin: auto auto auto 0;" />

## Geometric interpolation: in 2 dimensions

Because the stacks lie in two dimensional space and because we need to
respect geographical features like roads, the actual interpolation is a
bit more complicated.

Consider the example of the “missing” observation that lies between
cases 32 and 122. Just as in the one dimensional example, the “missing”
observation should be located one *unit* away from case 32. The
difference in two dimensions is that it needs to be located one *unit*
away from case 32 (at the red “x”) as measured along the line that runs
through the stack’s axis (black dotted
line).

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-11-1.png" style="display: block; margin: auto auto auto 0;" />

To compute the coordinates for the “missing” case, I’m literally
computing the points of intersection between a circle and line.

The circle is simple: it’s center is the case serving as the reference
point (case 32); its radius is the desired multiple of the *unit*
distance, which is 1 in this example.

The line is equally simple, in theory: it’s the line that runs through
the stack’s axis.

In practice, computing the line is little complicated because the bars
in the stacks are generally *not* perfectly aligned. To ensure that
there is one, unique axis for each stack, I impose two constraints: 1) a
stack must lie along the axis that is orthogonal to the road (line
segment) where the stack is located\[1\]; and 2) the axis must pass
through the bar at the base of the stack (i.e., the bar closest to the
stack’s home road segment).

As a consequence, the line drawn through the stack’s axis will pass
through the circle’s
center:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-12-1.png" style="display: block; margin: auto auto auto 0;" />

There will, of course, be two points of intersection (red
squares):

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-13-1.png" style="display: block; margin: auto auto auto 0;" />

Finding the coordinates of the “missing” observations boils down to
solving a quadratic equation and picking the appropriate
solution.

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-14-1.png" style="display: block; margin: auto auto auto 0;" />

I do so using with the formulas below:

``` r
# Equation of line for the "home" road segment
# "segment" is the numeric ID of one of the 528 sets of line segments in Dodson and Tobler
segmentOLS <- function(segment) {
  lm(y ~ x, data = street.list[[segment]])
}

# Slope for orthogonal stack axis
orthogonalSlope <- function(segment) {
  ols <- segmentOLS(segment)
  -1 / coef(ols)[2]
}

# Intercept for orthogonal stack axis
# "case" if the reference point of a stack
orthogonalIntercept <- function(case, segment) {
  Snow.deaths[case, "y"] - orthogonalSlope(segment) * Snow.deaths[case, "x"]
}

# unit distance is a function of the Euclidean distance between "case1" and "case2"
unitDistance <- function(case1, case2) {
  dist(Snow.deaths[c(case1, case2), c("x", "y")])
}

# Quadratic equation
quadratic <- function(a, b, c) {
  root1 <- (-b + sqrt(b^2 - 4 * a * c)) / (2 * a)
  root2 <- (-b - sqrt(b^2 - 4 * a * c)) / (2 * a)
  c(root1, root2)
}

# Geometric interpolation
# "multiplier" scales and defines the unit distance
interpolatedPoints <- function(case1, case2, segment, multiplier = 0.5) {
  p <- Snow.deaths[case1, "x"]
  q <- Snow.deaths[case1, "y"]
  radius <- multiplier * unitDistance(case1, case2)
  m <- orthogonalSlope(segment)
  b <- orthogonalIntercept(case1)
  A <- (m^2 + 1)
  B <- 2 * (m * b - m * q - p)
  C <- (q^2 - radius^2 + p^2 - 2 * b * q + b^2)
  quadratic(A, B, C)
}
```

## Proposed coordinates

Using this approach, I get the following results. For the two “missing”
cases at 40 Broad Street, I move two duplicates, cases 91 and 93, from
Cambridge
Street:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-16-1.png" style="display: block; margin: auto auto auto 0;" />

For the missing case at 15 Noel Street, I move the remaining duplicate,
case 209, from Cambridge
Street:

<img src="duplicate.missing.cases.notes_files/figure-gfm/unnamed-chunk-17-1.png" style="display: block; margin: auto auto auto 0;" />

## Notes

1.  For an explanation on how the home road segment is identified, see
    the “‘Unstacking’ Bars” vignette.
