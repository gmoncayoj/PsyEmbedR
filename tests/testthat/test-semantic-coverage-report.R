test_that("semantic_coverage_report validates expected_dimension length", {
  expect_error(
    semantic_coverage_report(
      items = c("Item A", "Item B"),
      definitions = c(adaptive = "Definition A", ecological = "Definition B"),
      expected_dimension = "adaptive"
    ),
    "must have the same length as `items`"
  )
})

test_that("semantic_coverage_report summarizes semantic coverage and misalignment", {
  alignment_long <- tibble::tibble(
    item_id = c(1L, 1L, 2L, 2L, 3L, 3L),
    item_text = c("Item A", "Item A", "Item B", "Item B", "Item C", "Item C"),
    definition = c("adaptive", "ecological", "adaptive", "ecological", "adaptive", "ecological"),
    cosine_similarity = c(0.91, 0.30, 0.35, 0.88, 0.82, 0.60),
    best_match = c("adaptive", "adaptive", "ecological", "ecological", "adaptive", "adaptive"),
    best_similarity = c(0.91, 0.91, 0.88, 0.88, 0.82, 0.82)
  )

  local_mocked_bindings(
    align_to_definition = function(items, definitions, model_name, envname) {
      alignment_long
    },
    .package = "PsyEmbedR"
  )

  output <- semantic_coverage_report(
    items = c("Item A", "Item B", "Item C"),
    definitions = c(adaptive = "Definition A", ecological = "Definition B"),
    expected_dimension = c("adaptive", "ecological", "ecological")
  )

  expect_type(output, "list")
  expect_named(
    output,
    c(
      "alignment_long",
      "best_alignment",
      "summary_by_dimension",
      "classification_summary",
      "misaligned_items"
    )
  )
  expect_equal(nrow(output$best_alignment), 3L)
  expect_equal(output$summary_by_dimension$n_items[output$summary_by_dimension$definition == "adaptive"], 2L)
  expect_equal(output$classification_summary$correctly_aligned, 2)
  expect_equal(output$classification_summary$misaligned, 1)
  expect_equal(output$classification_summary$unaligned_items, 0)
  expect_equal(output$misaligned_items$item_id, 3L)
  expect_equal(output$misaligned_items$semantic_dimension, "adaptive")
})
