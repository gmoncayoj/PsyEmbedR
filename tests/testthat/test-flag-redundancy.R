test_that("flag_redundancy validates threshold", {
  expect_error(flag_redundancy("Item A", threshold = 2), "interval \\[0, 1\\]")
})

test_that("flag_redundancy identifies highly similar item pairs", {
  local_mocked_bindings(
    embed_items = function(items, model_name, envname, normalize = TRUE) {
      rbind(
        c(1, 0),
        c(0.99, 0.01),
        c(0, 1)
      )
    },
    .package = "PsyEmbedR"
  )

  output <- flag_redundancy(
    items = c("Item A", "Item B", "Item C"),
    threshold = 0.95
  )

  expect_s3_class(output, "tbl_df")
  expect_equal(nrow(output), 1L)
  expect_equal(output$item_id_1, 1L)
  expect_equal(output$item_id_2, 2L)
  expect_true(output$cosine_similarity >= 0.95)
})

test_that("flag_redundancy returns an empty tibble when no pairs are flagged", {
  local_mocked_bindings(
    embed_items = function(items, model_name, envname, normalize = TRUE) {
      rbind(
        c(1, 0),
        c(0, 1)
      )
    },
    .package = "PsyEmbedR"
  )

  output <- flag_redundancy(
    items = c("Item A", "Item B"),
    threshold = 0.90
  )

  expect_s3_class(output, "tbl_df")
  expect_equal(nrow(output), 0L)
})
