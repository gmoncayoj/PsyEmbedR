#' Detect the dominant language of a text set
#'
#' Performs a lightweight local heuristic over the supplied texts and
#' returns one of `"es"`, `"en"`, `"mixed"`, or `"unknown"`.
#' The heuristic is intended to support model selection for short
#' psychometric items and definitions without relying on external
#' services.
#'
#' @param texts Character vector containing the texts to inspect.
#'
#' @return A single character value indicating the detected language:
#'   `"es"`, `"en"`, `"mixed"`, or `"unknown"`.
#' @export
#'
#' @examples
#' detect_text_language(c(
#'   "Me adapto cuando cambian las circunstancias.",
#'   "Mi familia me brinda apoyo."
#' ))
#'
#' detect_text_language(c(
#'   "I adapt when circumstances change.",
#'   "My family gives me support."
#' ))
detect_text_language <- function(texts) {
  texts <- .validate_character_vector(texts, "texts")
  .detect_text_language_internal(texts)
}
