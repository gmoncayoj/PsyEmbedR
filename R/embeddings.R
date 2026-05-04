#' Generate sentence embeddings for item texts
#'
#' Encodes a character vector of item texts with a local
#' `sentence-transformers` model accessed from R through `reticulate`.
#'
#' @param items Character vector with one item text per element.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the text language.
#'   When `"auto"` is used, the package selects
#'   `"sentence-transformers/all-mpnet-base-v2"` for English-only text
#'   and `"sentence-transformers/paraphrase-multilingual-mpnet-base-v2"`
#'   otherwise.
#' @param envname Name of the Python virtual environment to activate.
#' @param normalize Logical scalar. If `TRUE`, embeddings are L2
#'   normalized by the Python model before being returned.
#'
#' @return A numeric matrix with one row per input item and one column
#'   per embedding dimension.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "I adapt quickly when plans change.",
#'   "I recover well after difficult situations."
#' )
#'
#' emb <- embed_items(items)
#' dim(emb)
#' }
embed_items <- function(
    items,
    model_name = "auto",
    envname = "r-psyembedr",
    normalize = TRUE) {
  items <- .validate_character_vector(items, "items")
  envname <- .validate_single_string(envname, "envname")
  normalize <- .validate_scalar_logical(normalize, "normalize")

  model_spec <- .resolve_model_spec(model_name = model_name, texts = items)
  model <- .load_sentence_transformer(
    model_name = model_spec$model_name,
    envname = envname
  )

  .encode_with_model(
    model,
    texts = items,
    normalize = normalize,
    row_prefix = "item"
  ) |>
    .attach_model_metadata(model_spec)
}
