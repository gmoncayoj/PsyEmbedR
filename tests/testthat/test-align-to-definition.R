test_that("align_to_definition validates definitions", {
  expect_error(
    align_to_definition("Item A", c("Definition A", "Definition B")),
    "Example: c\\(Control = 'Definition A', Autonomia = 'Definition B'\\)"
  )
})

test_that("align_to_definition returns the expected long tibble shape", {
  local_mocked_bindings(
    .load_sentence_transformer = function(model_name, envname) {
      list(model_name = model_name, envname = envname)
    },
    .encode_with_model = function(model, texts, normalize = TRUE, row_prefix = "item") {
      if (identical(texts, c("Item A", "Item B"))) {
        return(rbind(c(1, 0), c(0, 1)))
      }

      if (identical(texts, c("Definition A", "Definition B"))) {
        return(rbind(c(1, 0), c(0, 1)))
      }

      stop("Unexpected texts in mocked encoder.")
    },
    .package = "PsyEmbedR"
  )

  definitions <- c(adaptive = "Definition A", ecological = "Definition B")
  output <- align_to_definition(c("Item A", "Item B"), definitions)

  expect_s3_class(output, "tbl_df")
  expect_equal(nrow(output), 4L)
  expect_named(
    output,
    c(
      "item_id",
      "item_text",
      "definition",
      "cosine_similarity",
      "best_match",
      "best_similarity"
    )
  )
  expect_equal(output$best_match[output$item_id == 1][1], "adaptive")
  expect_equal(output$best_match[output$item_id == 2][1], "ecological")
  expect_equal(output$best_similarity[output$item_id == 1][1], 1)
})
