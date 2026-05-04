test_that("cosine_matrix returns a symmetric matrix with unit diagonal", {
  embeddings <- rbind(
    c(1, 0),
    c(0, 1),
    c(1, 1)
  )

  similarity <- cosine_matrix(embeddings)

  expect_equal(dim(similarity), c(3, 3))
  expect_equal(similarity, t(similarity))
  expect_equal(diag(similarity), c(1, 1, 1))
  expect_equal(unname(similarity[1, 2]), 0)
})

test_that("cosine_matrix rejects rows with zero norm", {
  embeddings <- rbind(
    c(1, 0),
    c(0, 0)
  )

  expect_error(
    cosine_matrix(embeddings),
    "contains at least one row with zero norm"
  )
})

test_that("cosine_matrix validates non-numeric input", {
  expect_error(cosine_matrix(matrix("a", nrow = 1L)), "`embeddings` must be numeric.")
})
