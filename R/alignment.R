#' Align items to named theoretical definitions
#'
#' Computes semantic similarity between item texts and a named vector of
#' theoretical definitions, then reports both the full similarity table
#' and the best matching definition for each item.
#'
#' @param items Character vector with one item text per element.
#' @param definitions Named character vector in which names identify the
#'   theoretical dimensions and values contain their textual definitions.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the combined text
#'   language of `items` and `definitions`.
#' @param envname Name of the Python virtual environment to activate.
#'
#' @return A tibble in long format with the columns `item_id`,
#'   `item_text`, `definition`, `cosine_similarity`, `best_match`, and
#'   `best_similarity`.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "I notice quickly when my environment changes.",
#'   "I adjust my behavior to meet changing demands."
#' )
#'
#' definitions <- c(
#'   ecological = "Sensitivity to cues and affordances in the environment.",
#'   adaptive = "Capacity to change behavior effectively in response to demands."
#' )
#'
#' align_to_definition(items, definitions)
#' }
align_to_definition <- function(
    items,
    definitions,
    model_name = "auto",
    envname = "r-psyembedr") {
  items <- .validate_character_vector(items, "items")
  definitions <- .validate_character_vector(
    definitions,
    arg = "definitions",
    require_names = TRUE
  )
  envname <- .validate_single_string(envname, "envname")
  model_spec <- .resolve_model_spec(
    model_name = model_name,
    texts = c(items, unname(definitions))
  )

  model <- .load_sentence_transformer(
    model_name = model_spec$model_name,
    envname = envname
  )
  item_embeddings <- .encode_with_model(
    model,
    texts = items,
    normalize = TRUE,
    row_prefix = "item"
  )
  definition_embeddings <- .encode_with_model(
    model,
    texts = unname(definitions),
    normalize = TRUE,
    row_prefix = "definition"
  )

  rownames(definition_embeddings) <- names(definitions)

  similarity_matrix <- .pairwise_cosine_similarity(
    item_embeddings,
    definition_embeddings,
    x_arg = "item_embeddings",
    y_arg = "definition_embeddings"
  )

  best_index <- max.col(similarity_matrix, ties.method = "first")
  best_alignment <- tibble::tibble(
    item_id = seq_along(items),
    best_match = names(definitions)[best_index],
    best_similarity = similarity_matrix[cbind(seq_along(items), best_index)]
  )

  tidyr::expand_grid(
    item_id = seq_along(items),
    definition = names(definitions)
  ) |>
    dplyr::mutate(
      item_text = items[item_id],
      cosine_similarity = purrr::map2_dbl(
        item_id,
        definition,
        ~ similarity_matrix[.x, .y]
      )
    ) |>
    dplyr::left_join(best_alignment, by = "item_id") |>
    dplyr::select(
      item_id,
      item_text,
      definition,
      cosine_similarity,
      best_match,
      best_similarity
    ) |>
    .attach_model_metadata(model_spec)
}
