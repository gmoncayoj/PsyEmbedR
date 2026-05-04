test_that("embed_items validates `items` before Python is used", {
  expect_error(embed_items(1), "`items` must be a character vector.")
  expect_error(embed_items(character()), "must contain at least one text value")
  expect_error(embed_items(c("valid text", "")), "must not contain missing or empty strings")
})

test_that("embed_items validates scalar arguments", {
  expect_error(
    embed_items("valid text", model_name = ""),
    "`model_name` must be a single non-empty string."
  )
  expect_error(
    embed_items("valid text", envname = NA_character_),
    "`envname` must be a single non-empty string."
  )
  expect_error(
    embed_items("valid text", normalize = NA),
    "`normalize` must be either TRUE or FALSE."
  )
})

test_that("embed_items auto-selects the English model for English text", {
  chosen_model <- NULL

  local_mocked_bindings(
    .load_sentence_transformer = function(model_name, envname) {
      chosen_model <<- model_name
      list(model_name = model_name, envname = envname)
    },
    .encode_with_model = function(model, texts, normalize = TRUE, row_prefix = "item") {
      matrix(c(1, 0), nrow = 1L)
    },
    .package = "PsyEmbedR"
  )

  output <- embed_items("I adapt when plans change.")

  expect_equal(chosen_model, "sentence-transformers/all-mpnet-base-v2")
  expect_equal(attr(output, "language_detected"), "en")
  expect_equal(attr(output, "model_selection"), "auto")
})

test_that("single-item embeddings are coerced to one-row matrices", {
  helper <- getFromNamespace(".as_numeric_matrix", "PsyEmbedR")

  one_dimensional_array <- structure(
    c(0.1, 0.2, 0.3, 0.4),
    dim = 4L
  )

  output <- helper(one_dimensional_array, arg = "embeddings")

  expect_equal(dim(output), c(1L, 4L))
  expect_equal(as.numeric(output[1, ]), c(0.1, 0.2, 0.3, 0.4))
})

test_that(".encode_with_model passes a list of texts to Python-style encoders", {
  encode_helper <- getFromNamespace(".encode_with_model", "PsyEmbedR")

  local_mocked_bindings(
    r_to_py = function(x) x,
    py_to_r = function(x) x,
    .package = "reticulate"
  )

  model <- list(
    encode = function(texts, convert_to_numpy, normalize_embeddings, show_progress_bar) {
      expect_type(texts, "list")
      expect_length(texts, 1L)
      expect_identical(texts[[1]], "Single item")
      expect_true(convert_to_numpy)
      expect_true(normalize_embeddings)
      expect_false(show_progress_bar)

      structure(c(0.5, 0.6, 0.7), dim = 3L)
    }
  )

  output <- encode_helper(
    model = model,
    texts = "Single item",
    normalize = TRUE
  )

  expect_equal(dim(output), c(1L, 3L))
  expect_equal(rownames(output), "item_1")
})
