methods::setClass(
  "NgramModel",
  slots = c(
    "update" = "function",
    "lpmf" = "function"
  )
)

Rcpp::loadModule("ngm_module", what = TRUE)

#' @title Ngram Model
#' @description
#' Fit and evaluate a character ngram Markov model.
#' @param n `[integer]` (default `3L`)
#' 
#' The "n" in "ngram". Length of substring to use.
#' E.g. "<<hello>" has substrings `c("<<h", "<he", "hel", "ell", "llo", "lo>")`
#' with `n=3`.
#' @param alpha `[numeric]` (default `1.0`)
#' 
#' Dirichlet model alpha parameter. Higher means all transition probabilities
#' approach `1/n` where `n` is the number of possible states.
#' @param unseen_alpha `[numeric]` (default `1.0`)
#' 
#' Similar to alpha, but for unseen data. E.g. if substring "<<x" has never
#' been seen in the training data, it would have a probability of zero
#' with `unseen_alpha = 0.0` but a probability above zero with 
#' `unseen_alpha > 0.0`.
#' @param normalise_length `[logical]` (default `TRUE`)
#' 
#' The Markov model has an inherent length bias, where long strings become very
#' unlikely to observed. With `normalise_length = TRUE`, slot `lpmf`
#' returns the geometric mean of the ngrams of a string instead of the raw
#' probability (at the log scale). Note that these are no longer probabilities
#' --- if evaluated on all possible strings, the sum would be larger than one.
#' @examples
#' # ngmr::NgramModel
#' nm <- ngmr::NgramModel()
#' nm@update("<<a>")
#' nm@lpmf("<<b>")
#' @export
NgramModel <- function(
  n = 3L,
  alpha = 1.0,
  unseen_alpha = 1.0,
  normalise_length = TRUE
) {
  out <- local({
    rcpp_ngram_model <- new(
      RcppNgramModel,
      n = n,
      alpha = alpha,
      unseen_alpha = unseen_alpha,
      normalise_length = normalise_length
    )
    #' @slot update Update Markov model with additional texts.
    #' It has parameter `texts` `[character]`.
    update <- function(
      texts
    ) {
      rcpp_ngram_model$update_texts(texts)
    }
    #' @slot lpmf Evaluate Markov model log-probabilities.
    #' It has parameters `texts` `[character]` (no default) and
    #' `n_threads` `[integer]` (default `1L`).
    #' The latter controls the number of threads to use when evaluating
    #' log-probabilities. Handy when `texts` is large.
    lpmf <- function(
      texts,
      n_threads = 1L
    ) {
      rcpp_ngram_model$lpmf_texts(texts, n_threads)
    }
    new(
      "NgramModel",
      update = update,
      lpmf = lpmf
    )
  })
  return(out)
}
