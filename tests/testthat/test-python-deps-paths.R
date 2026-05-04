test_that("virtualenv helper uses dirname for explicit environment paths", {
  helper <- getFromNamespace(".virtualenv_parent_dir", "PsyEmbedR")

  env_path <- file.path(tempdir(), "nested-root", "r-psyembedr")

  expect_identical(helper(env_path), dirname(env_path))
})

test_that("virtualenv helper creates missing parent directories", {
  helper <- getFromNamespace(".ensure_virtualenv_parent_dir", "PsyEmbedR")

  root_dir <- file.path(tempdir(), paste0("psyembedr-test-", Sys.getpid()))
  env_path <- file.path(root_dir, "deep", "r-psyembedr")
  parent_dir <- dirname(env_path)

  if (dir.exists(root_dir)) {
    unlink(root_dir, recursive = TRUE, force = TRUE)
  }

  expect_false(dir.exists(parent_dir))

  helper(env_path)

  expect_true(dir.exists(parent_dir))

  unlink(root_dir, recursive = TRUE, force = TRUE)
})
