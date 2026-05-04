test_that("detect_text_language identifies Spanish text", {
  output <- detect_text_language(c(
    "Me adapto cuando cambian las circunstancias.",
    "Mi familia me brinda apoyo."
  ))

  expect_equal(output, "es")
})

test_that("detect_text_language identifies English text", {
  output <- detect_text_language(c(
    "I adapt when circumstances change.",
    "My family gives me support."
  ))

  expect_equal(output, "en")
})

test_that("detect_text_language identifies mixed text", {
  output <- detect_text_language(c(
    "I adapt when circumstances change.",
    "Mi familia me brinda apoyo."
  ))

  expect_equal(output, "mixed")
})
