test_that("plot_semantic_map validates method before plotting", {
  expect_error(
    plot_semantic_map(
      items = c("Item A", "Item B"),
      method = "invalid-method"
    ),
    "`method` must be one of: mds, pca."
  )
})

test_that("plot_semantic_map validates color inputs before plotting", {
  expect_error(
    plot_semantic_map(
      items = c("Item A", "Item B"),
      color_by = "inferred"
    ),
    "`definitions` must be supplied when `color_by = 'inferred'`."
  )

  expect_error(
    plot_semantic_map(
      items = c("Item A", "Item B"),
      color_by = "expected"
    ),
    "`expected_dimension` must be supplied when `color_by = 'expected'`."
  )
})

test_that("plot_semantic_map returns a ggplot object with coordinates", {
  skip_if_not_installed("ggplot2")

  mocked_embeddings <- rbind(
    c(1, 0),
    c(0.8, 0.2),
    c(0, 1)
  )

  attr(mocked_embeddings, "model_name_used") <- "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
  attr(mocked_embeddings, "language_detected") <- "es"
  attr(mocked_embeddings, "model_selection") <- "auto"

  local_mocked_bindings(
    embed_items = function(items, model_name, envname, normalize = TRUE) {
      mocked_embeddings
    },
    .package = "PsyEmbedR"
  )

  plot_object <- plot_semantic_map(
    items = c("Item A", "Item B", "Item C"),
    method = "mds"
  )

  expect_s3_class(plot_object, "ggplot")
  expect_true(is.data.frame(attr(plot_object, "semantic_coordinates")))
  expect_equal(nrow(attr(plot_object, "semantic_coordinates")), 3L)
  expect_equal(attr(plot_object, "language_detected"), "es")
})

test_that("plot_semantic_map stores semantic groups when colored by inferred dimension", {
  skip_if_not_installed("ggplot2")

  mocked_embeddings <- rbind(
    c(1, 0),
    c(0.8, 0.2),
    c(0, 1)
  )

  attr(mocked_embeddings, "model_name_used") <- "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
  attr(mocked_embeddings, "language_detected") <- "es"
  attr(mocked_embeddings, "model_selection") <- "auto"

  local_mocked_bindings(
    embed_items = function(items, model_name, envname, normalize = TRUE) {
      mocked_embeddings
    },
    infer_dimensions = function(items, definitions, model_name, envname, min_similarity, unaligned_label) {
      tibble::tibble(
        item_id = 1:3,
        item_text = items,
        nearest_definition = c("adaptive", "ecological", "adaptive"),
        predicted_dimension = c("adaptive", "ecological", "no clear alignment"),
        predicted_similarity = c(0.90, 0.82, 0.12),
        meets_similarity_threshold = c(TRUE, TRUE, FALSE),
        alignment_note = c("ok", "ok", "low")
      )
    },
    .package = "PsyEmbedR"
  )

  plot_object <- plot_semantic_map(
    items = c("Item A", "Item B", "Item C"),
    definitions = c(adaptive = "Definition A", ecological = "Definition B"),
    color_by = "inferred"
  )

  expect_s3_class(plot_object, "ggplot")
  expect_true(is.data.frame(attr(plot_object, "semantic_groups")))
  expect_equal(attr(plot_object, "semantic_groups")$semantic_group[3], "no clear alignment")
})

test_that("plot_semantic_map validates label_method before plotting", {
  expect_error(
    plot_semantic_map(
      items = c("Item A", "Item B"),
      label_method = "bad-option"
    ),
    "`label_method` must be one of: auto, repel, text, none."
  )
})
