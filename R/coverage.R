#' Summarize semantic coverage across theoretical dimensions
#'
#' Uses `align_to_definition()` to summarize how many items are closest
#' to each theoretical definition. When an expected dimension is
#' provided, the function also compares expected and semantic
#' classifications and identifies misaligned items.
#'
#' @param items Character vector with one item text per element.
#' @param definitions Named character vector in which names identify the
#'   theoretical dimensions and values contain their textual definitions.
#' @param expected_dimension Optional character vector with the expected
#'   dimension for each item, in the same order as `items`.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the combined text
#'   language of `items` and `definitions`.
#' @param envname Name of the Python virtual environment to activate.
#' @param min_similarity Minimum cosine similarity required to treat the
#'   best match as a usable semantic assignment in the summary.
#' @param unaligned_label Label assigned to items that do not reach
#'   `min_similarity`.
#'
#' @return A list with components `alignment_long`, `best_alignment`,
#'   `summary_by_dimension`, `classification_summary`, and
#'   `misaligned_items`. The last two elements are `NULL` when
#'   `expected_dimension` is not supplied.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "I adapt my plans when new demands appear.",
#'   "I quickly detect relevant changes in my environment.",
#'   "I recover my focus after setbacks."
#' )
#'
#' definitions <- c(
#'   adaptive = "Flexible behavior change in response to situational demands.",
#'   ecological = "Detection of relevant cues in the surrounding environment.",
#'   resilient = "Recovery of effective functioning after challenge or stress."
#' )
#'
#' semantic_coverage_report(
#'   items = items,
#'   definitions = definitions,
#'   expected_dimension = c("adaptive", "ecological", "resilient")
#' )
#' }
semantic_coverage_report <- function(
    items,
    definitions,
    expected_dimension = NULL,
    model_name = "auto",
    envname = "r-psyembedr",
    min_similarity = 0.20,
    unaligned_label = "no clear alignment") {
  items <- .validate_character_vector(items, "items")
  definitions <- .validate_character_vector(
    definitions,
    arg = "definitions",
    require_names = TRUE
  )
  envname <- .validate_single_string(envname, "envname")
  min_similarity <- .validate_threshold(min_similarity)
  unaligned_label <- .validate_single_string(unaligned_label, "unaligned_label")

  if (!is.null(expected_dimension)) {
    expected_dimension <- .validate_expected_dimension(
      expected_dimension = expected_dimension,
      definitions = definitions,
      n_items = length(items)
    )
  }

  alignment_long <- align_to_definition(
    items = items,
    definitions = definitions,
    model_name = model_name,
    envname = envname
  )

  best_alignment <- infer_dimensions(
    items = items,
    definitions = definitions,
    model_name = model_name,
    envname = envname,
    min_similarity = min_similarity,
    unaligned_label = unaligned_label
  )

  summary_by_dimension <- best_alignment |>
    dplyr::count(predicted_dimension, name = "n_items") |>
    dplyr::rename(definition = predicted_dimension) |>
    tidyr::complete(
      definition = c(names(definitions), unaligned_label),
      fill = list(n_items = 0L)
    ) |>
    dplyr::left_join(
      best_alignment |>
        dplyr::group_by(predicted_dimension) |>
        dplyr::summarise(
          mean_predicted_similarity = mean(predicted_similarity),
          .groups = "drop"
        ) |>
        dplyr::rename(definition = predicted_dimension),
      by = "definition"
    ) |>
    dplyr::mutate(proportion = n_items / sum(n_items)) |>
    dplyr::arrange(dplyr::desc(n_items), definition)

  classification_summary <- NULL
  misaligned_items <- NULL

  if (!is.null(expected_dimension)) {
    classified <- best_alignment |>
      dplyr::mutate(
        expected_dimension = expected_dimension,
        semantic_dimension = predicted_dimension,
        is_aligned = expected_dimension == semantic_dimension
      )

    classification_summary <- classified |>
      dplyr::summarise(
        total_items = dplyr::n(),
        correctly_aligned = sum(is_aligned),
        misaligned = sum(!is_aligned),
        unaligned_items = sum(!meets_similarity_threshold),
        accuracy = sum(is_aligned) / dplyr::n()
      )

    misaligned_items <- classified |>
      dplyr::filter(!is_aligned) |>
      dplyr::select(
        item_id,
        item_text,
        expected_dimension,
        semantic_dimension,
        predicted_similarity,
        alignment_note
      )
  }

  output <- list(
    alignment_long = alignment_long,
    best_alignment = best_alignment,
    summary_by_dimension = summary_by_dimension,
    classification_summary = classification_summary,
    misaligned_items = misaligned_items
  )

  .attach_model_metadata(output, list(
    model_name = attr(alignment_long, "model_name_used"),
    language = attr(alignment_long, "language_detected"),
    selection = attr(alignment_long, "model_selection")
  ))
}
