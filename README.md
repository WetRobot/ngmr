
# ngmr

<!-- badges: start -->
<!-- badges: end -->

Fit and evaluate ngram Markov models.

## Installation

You can install the development version of ngmr like so:

``` r
devtools::install("github::WetRobot/ngmr")
```

## Example

``` r
nm <- ngmr::NgramModel()
nm@update("<<a>")
nm@lpmf("<<b>")
```

