#' Ensure local Python dependencies for PsyEmbedR
#'
#' Verifies that the requested Python virtual environment exists, creates
#' it if needed, installs the required Python packages, activates the
#' environment through `reticulate`, and checks that
#' `sentence_transformers` is available. When the parent directory of the
#' target virtual environment does not exist yet, `PsyEmbedR` creates it
#' first to make first-run setup more robust across machines. If Python
#' has already been initialized elsewhere in the current R session, the
#' function reuses the active interpreter and attempts to install missing
#' dependencies there.
#'
#' @param envname Name of the virtual environment managed by
#'   `reticulate`.
#' @param python Optional path to a Python interpreter to use when the
#'   environment is created for the first time.
#'
#' @return Invisibly returns a list with the virtual environment name,
#'   the active Python interpreter, and the Python modules checked by the
#'   function.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#' ensure_python_deps(envname = "r-psyembedr", python = "C:/Python311/python.exe")
#' }
ensure_python_deps <- function(envname = "r-psyembedr", python = NULL) {
  envname <- .validate_single_string(envname, "envname")

  if (!is.null(python)) {
    python <- .validate_single_string(python, "python")
  }

  env_exists <- tryCatch(
    reticulate::virtualenv_exists(envname),
    error = function(cnd) {
      cli::cli_abort(c(
        "The Python virtual environment could not be inspected.",
        "x" = conditionMessage(cnd)
      ))
    }
  )

  compatibility <- .ensure_python_session_compatible(
    envname,
    env_exists = env_exists
  )

  if (identical(compatibility$mode, "active")) {
    .ensure_active_python_dependencies()

    config <- reticulate::py_config()

    cli::cli_inform(glue::glue(
      "PsyEmbedR will use the active Python interpreter at `{config$python}` in this session."
    ))

    return(invisible(list(
      envname = envname,
      python = config$python,
      modules = unname(.required_python_modules()),
      session_mode = "active"
    )))
  }

  if (!env_exists) {
    .ensure_virtualenv_parent_dir(envname)

    cli::cli_inform(glue::glue(
      "Creating Python virtual environment `{envname}` for PsyEmbedR."
    ))

    tryCatch(
      reticulate::virtualenv_create(envname = envname, python = python),
      error = function(cnd) {
        cli::cli_abort(c(
          "The Python virtual environment could not be created.",
          "x" = conditionMessage(cnd)
        ))
      }
    )
  }

  .activate_virtualenv(envname)

  module_map <- .required_python_modules()
  missing_modules <- names(module_map)[
    !purrr::map_lgl(unname(module_map), reticulate::py_module_available)
  ]

  if (!env_exists || length(missing_modules) > 0L) {
    cli::cli_inform(glue::glue(
      "Installing Python dependencies into virtual environment `{envname}`."
    ))

    tryCatch(
      reticulate::virtualenv_install(
        envname = envname,
        packages = .required_python_packages(),
        ignore_installed = FALSE
      ),
      error = function(cnd) {
        cli::cli_abort(c(
          "The required Python packages could not be installed.",
          "x" = conditionMessage(cnd)
        ))
      }
    )

    .activate_virtualenv(envname)
    missing_modules <- names(module_map)[
      !purrr::map_lgl(unname(module_map), reticulate::py_module_available)
    ]
  }

  if (length(missing_modules) > 0L) {
    cli::cli_abort(c(
      "The Python environment is still missing required modules.",
      "x" = glue::glue("Missing modules: {paste(missing_modules, collapse = ', ')}"),
      "i" = "Verify that Python and pip are available to `reticulate` and retry."
    ))
  }

  config <- reticulate::py_config()

  cli::cli_inform(glue::glue(
    "Python environment `{envname}` is ready at `{config$python}`."
  ))

  invisible(list(
    envname = envname,
    python = config$python,
    modules = unname(module_map),
    session_mode = "virtualenv"
  ))
}
