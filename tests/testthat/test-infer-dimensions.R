test_that("infer_dimensions returns one predicted dimension per item", {
  alignment_long <- tibble::tibble(
    item_id = c(1L, 1L, 2L, 2L),
    item_text = c("Item A", "Item A", "Item B", "Item B"),
    definition = c("adaptive", "ecological", "adaptive", "ecological"),
    cosine_similarity = c(0.91, 0.40, 0.30, 0.88),
    best_match = c("adaptive", "adaptive", "ecological", "ecological"),
    best_similarity = c(0.91, 0.91, 0.88, 0.88)
  )

  attr(alignment_long, "model_name_used") <- "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
  attr(alignment_long, "language_detected") <- "es"
  attr(alignment_long, "model_selection") <- "auto"

  local_mocked_bindings(
    align_to_definition = function(items, definitions, model_name, envname) {
      alignment_long
    },
    .package = "PsyEmbedR"
  )

  output <- infer_dimensions(
    items = c("Item A", "Item B"),
    definitions = c(adaptive = "Definition A", ecological = "Definition B")
  )

  expect_s3_class(output, "tbl_df")
  expect_named(
    output,
    c(
      "item_id",
      "item_text",
      "nearest_definition",
      "predicted_dimension",
      "predicted_similarity",
      "meets_similarity_threshold",
      "alignment_note"
    )
  )
  expect_equal(output$nearest_definition, c("adaptive", "ecological"))
  expect_equal(output$predicted_dimension, c("adaptive", "ecological"))
  expect_equal(output$predicted_similarity, c(0.91, 0.88))
  expect_true(all(output$meets_similarity_threshold))
  expect_equal(attr(output, "language_detected"), "es")
  expect_equal(attr(output, "model_selection"), "auto")
})

test_that("infer_dimensions flags low-similarity items as unaligned", {
  alignment_long <- tibble::tibble(
    item_id = c(1L, 1L),
    item_text = c("Item A", "Item A"),
    definition = c("adaptive", "ecological"),
    cosine_similarity = c(0.12, 0.08),
    best_match = c("adaptive", "adaptive"),
    best_similarity = c(0.12, 0.12)
  )

  attr(alignment_long, "model_name_used") <- "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
  attr(alignment_long, "language_detected") <- "es"
  attr(alignment_long, "model_selection") <- "auto"

  local_mocked_bindings(
    align_to_definition = function(items, definitions, model_name, envname) {
      alignment_long
    },
    .package = "PsyEmbedR"
  )

  output <- infer_dimensions(
    items = "Item A",
    definitions = c(adaptive = "Definition A", ecological = "Definition B"),
    min_similarity = 0.20
  )

  expect_equal(output$nearest_definition, "adaptive")
  expect_equal(output$predicted_dimension, "no clear alignment")
  expect_false(output$meets_similarity_threshold)
  expect_match(output$alignment_note, "may not align semantically")
})
