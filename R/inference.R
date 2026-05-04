#' Infer the most likely definition for each item
#'
#' Provides a one-row-per-item semantic classification based on the
#' highest cosine similarity between each item and the supplied
#' theoretical definitions.
#'
#' @param items Character vector with one item text per element.
#' @param definitions Named character vector in which names identify the
#'   theoretical dimensions and values contain their textual definitions.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the text language.
#' @param envname Name of the Python virtual environment to activate.
#' @param min_similarity Minimum cosine similarity required to treat the
#'   best match as a usable semantic assignment. Values below this
#'   threshold are flagged as lacking a clear semantic alignment.
#' @param unaligned_label Label assigned when `predicted_similarity` is
#'   below `min_similarity`.
#'
#' @return A tibble with the columns `item_id`, `item_text`,
#'   `nearest_definition`, `predicted_dimension`,
#'   `predicted_similarity`, `meets_similarity_threshold`, and
#'   `alignment_note`.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "Me adapto cuando cambian las circunstancias.",
#'   "Mi familia me brinda apoyo cuando lo necesito."
#' )
#'
#' definitions <- c(
#'   adaptive = "Capacidad de ajustarse flexiblemente a cambios y exigencias.",
#'   ecological = "Recursos familiares y sociales que facilitan el afrontamiento."
#' )
#'
#' infer_dimensions(items, definitions)
#' }
infer_dimensions <- function(
    items,
    definitions,
    model_name = "auto",
    envname = "r-psyembedr",
    min_similarity = 0.20,
    unaligned_label = "no clear alignment") {
  min_similarity <- .validate_threshold(min_similarity)
  unaligned_label <- .validate_single_string(unaligned_label, "unaligned_label")

  alignment <- align_to_definition(
    items = items,
    definitions = definitions,
    model_name = model_name,
    envname = envname
  )

  model_spec <- list(
    model_name = attr(alignment, "model_name_used"),
    language = attr(alignment, "language_detected"),
    selection = attr(alignment, "model_selection")
  )

  alignment |>
    dplyr::distinct(
      item_id,
      item_text,
      nearest_definition = best_match,
      predicted_similarity = best_similarity
    ) |>
    dplyr::mutate(
      meets_similarity_threshold = predicted_similarity >= min_similarity,
      predicted_dimension = dplyr::if_else(
        meets_similarity_threshold,
        nearest_definition,
        unaligned_label
      ),
      alignment_note = dplyr::if_else(
        meets_similarity_threshold,
        "Semantic alignment is above the minimum similarity threshold.",
        glue::glue(
          "Best similarity is below {min_similarity}; the item may not align semantically with any supplied definition."
        )
      )
    ) |>
    dplyr::select(
      item_id,
      item_text,
      nearest_definition,
      predicted_dimension,
      predicted_similarity,
      meets_similarity_threshold,
      alignment_note
    ) |>
    dplyr::arrange(item_id) |>
    .attach_model_metadata(model_spec)
}
