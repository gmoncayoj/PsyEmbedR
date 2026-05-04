#' Flag semantically redundant item pairs
#'
#' Generates embeddings for a set of items, computes the cosine
#' similarity matrix, and returns item pairs whose similarity meets or
#' exceeds a chosen threshold.
#'
#' @param items Character vector with one item text per element.
#' @param threshold Numeric scalar in the interval `[0, 1]`. Pairs with
#'   cosine similarity greater than or equal to this value are flagged.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the item text
#'   language.
#' @param envname Name of the Python virtual environment to activate.
#'
#' @return A tibble sorted from highest to lowest cosine similarity, with
#'   the columns `item_id_1`, `item_text_1`, `item_id_2`,
#'   `item_text_2`, and `cosine_similarity`.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "I adapt well to changing conditions.",
#'   "I adjust well when conditions change.",
#'   "I notice details in my surroundings."
#' )
#'
#' flag_redundancy(items, threshold = 0.85)
#' }
flag_redundancy <- function(
    items,
    threshold = 0.85,
    model_name = "auto",
    envname = "r-psyembedr") {
  items <- .validate_character_vector(items, "items")
  threshold <- .validate_threshold(threshold)
  envname <- .validate_single_string(envname, "envname")

  embeddings <- embed_items(
    items = items,
    model_name = model_name,
    envname = envname,
    normalize = TRUE
  )
  similarity_matrix <- cosine_matrix(embeddings)

  pair_index <- which(
    similarity_matrix >= threshold & upper.tri(similarity_matrix),
    arr.ind = TRUE
  )

  if (nrow(pair_index) == 0L) {
    return(.empty_redundancy_result())
  }

  tibble::tibble(
    item_id_1 = pair_index[, 1],
    item_text_1 = items[pair_index[, 1]],
    item_id_2 = pair_index[, 2],
    item_text_2 = items[pair_index[, 2]],
    cosine_similarity = similarity_matrix[pair_index]
  ) |>
    dplyr::arrange(dplyr::desc(cosine_similarity), item_id_1, item_id_2) |>
    .attach_model_metadata(list(
      model_name = attr(embeddings, "model_name_used"),
      language = attr(embeddings, "language_detected"),
      selection = attr(embeddings, "model_selection")
    ))
}
