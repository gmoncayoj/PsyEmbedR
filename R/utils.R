.required_python_packages <- function() {
  unname(.required_python_package_map())
}

.required_python_package_map <- function() {
  c(
    sentence_transformers = "sentence-transformers",
    torch = "torch",
    numpy = "numpy",
    scikit_learn = "scikit-learn"
  )
}

.required_python_modules <- function() {
  c(
    sentence_transformers = "sentence_transformers",
    torch = "torch",
    numpy = "numpy",
    scikit_learn = "sklearn"
  )
}

.default_multilingual_model <- function() {
  "sentence-transformers/paraphrase-multilingual-mpnet-base-v2"
}

.default_english_model <- function() {
  "sentence-transformers/all-mpnet-base-v2"
}

.required_python_module_status <- function() {
  module_map <- .required_python_modules()
  stats::setNames(
    purrr::map_lgl(unname(module_map), reticulate::py_module_available),
    names(module_map)
  )
}

.missing_required_python_modules <- function() {
  module_status <- .required_python_module_status()
  names(module_status)[!module_status]
}

.normalize_model_name_input <- function(model_name) {
  if (is.null(model_name)) {
    return("auto")
  }

  .validate_single_string(model_name, "model_name")
}

.validate_single_string <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(glue::glue("`{arg}` must be a single non-empty string."))
  }

  x <- stringr::str_trim(x)

  if (identical(x, "")) {
    cli::cli_abort(glue::glue("`{arg}` must be a single non-empty string."))
  }

  x
}

.validate_scalar_logical <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(glue::glue("`{arg}` must be either TRUE or FALSE."))
  }

  x
}

.validate_choice <- function(x, choices, arg) {
  x <- .validate_single_string(x, arg)

  if (!x %in% choices) {
    cli::cli_abort(c(
      glue::glue("`{arg}` must be one of: {paste(choices, collapse = ', ')}."),
      "x" = glue::glue("Received: {x}")
    ))
  }

  x
}

.validate_positive_number <- function(x, arg) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x <= 0) {
    cli::cli_abort(glue::glue("`{arg}` must be a single positive number."))
  }

  x
}

.named_vector_hint <- function(arg) {
  if (!identical(arg, "definitions")) {
    return(NULL)
  }

  c(
    "i" = "Example: c(Control = 'Definition A', Autonomia = 'Definition B')."
  )
}

.validate_optional_named_definitions <- function(definitions) {
  if (is.null(definitions)) {
    return(NULL)
  }

  .validate_character_vector(
    definitions,
    arg = "definitions",
    require_names = TRUE
  )
}

.validate_expected_dimension_any <- function(expected_dimension, n_items) {
  expected_dimension <- .validate_character_vector(
    expected_dimension,
    arg = "expected_dimension"
  )

  if (length(expected_dimension) != n_items) {
    cli::cli_abort("`expected_dimension` must have the same length as `items`.")
  }

  expected_dimension
}

.validate_character_vector <- function(x, arg, require_names = FALSE) {
  if (is.factor(x)) {
    x <- as.character(x)
  }

  if (!is.character(x)) {
    cli::cli_abort(glue::glue("`{arg}` must be a character vector."))
  }

  if (length(x) == 0L) {
    cli::cli_abort(glue::glue("`{arg}` must contain at least one text value."))
  }

  x <- stringr::str_trim(x)

  if (any(is.na(x) | x == "")) {
    cli::cli_abort(
      glue::glue("`{arg}` must not contain missing or empty strings.")
    )
  }

  if (require_names) {
    names_x <- names(x)

    if (is.null(names_x) || length(names_x) != length(x)) {
      cli::cli_abort(c(
        glue::glue("`{arg}` must be a named character vector with one name per element."),
        .named_vector_hint(arg)
      ))
    }

    names_x <- stringr::str_trim(names_x)

    if (!rlang::is_named(rlang::set_names(x, names_x))) {
      cli::cli_abort(c(
        glue::glue("`{arg}` must have non-empty names for every element."),
        .named_vector_hint(arg)
      ))
    }

    if (anyDuplicated(names_x)) {
      cli::cli_abort(glue::glue("`{arg}` must have unique names."))
    }

    names(x) <- names_x
  }

  x
}

.validate_threshold <- function(threshold) {
  if (!is.numeric(threshold) || length(threshold) != 1L || is.na(threshold)) {
    cli::cli_abort("`threshold` must be a single numeric value in the interval [0, 1].")
  }

  if (threshold < 0 || threshold > 1) {
    cli::cli_abort("`threshold` must be a single numeric value in the interval [0, 1].")
  }

  threshold
}

.validate_expected_dimension <- function(expected_dimension, definitions, n_items) {
  expected_dimension <- .validate_character_vector(
    expected_dimension,
    arg = "expected_dimension"
  )

  if (length(expected_dimension) != n_items) {
    cli::cli_abort("`expected_dimension` must have the same length as `items`.")
  }

  unknown_dimensions <- setdiff(unique(expected_dimension), names(definitions))

  if (length(unknown_dimensions) > 0L) {
    cli::cli_abort(c(
      "`expected_dimension` contains labels that are not present in `definitions`.",
      "x" = glue::glue(
        "Unknown labels: {paste(unknown_dimensions, collapse = ', ')}"
      )
    ))
  }

  expected_dimension
}

.strip_accents <- function(x) {
  iconv(x, to = "ASCII//TRANSLIT")
}

.normalize_language_text <- function(texts) {
  texts |>
    stringr::str_to_lower() |>
    .strip_accents() |>
    stringr::str_replace_all("[^a-z\\s]", " ") |>
    stringr::str_squish()
}

.spanish_language_markers <- function() {
  c(
    "de", "del", "la", "las", "el", "los", "me", "mi", "mis", "cuando",
    "despues", "porque", "para", "con", "sin", "situacion", "familia",
    "apoyo", "necesito", "personas", "cercanas", "problemas",
    "circunstancias", "ayudan", "afrontamiento", "ajustarse"
  )
}

.english_language_markers <- function() {
  c(
    "i", "my", "when", "after", "the", "those", "people", "family",
    "support", "need", "quickly", "change", "changes", "difficult",
    "situation", "adapt", "adjust", "plans", "demands", "around",
    "recovery", "context", "resources"
  )
}

.language_scores <- function(texts) {
  texts <- .validate_character_vector(texts, "texts")
  normalized <- .normalize_language_text(texts)
  token_list <- stringr::str_split(normalized, pattern = "\\s+")
  tokens <- unlist(token_list, use.names = FALSE)
  tokens <- tokens[tokens != ""]

  accent_hits <- sum(stringr::str_detect(texts, "[ÁÉÍÓÚáéíóúÑñÜü¿¡]"))
  spanish_hits <- sum(tokens %in% .spanish_language_markers())
  english_hits <- sum(tokens %in% .english_language_markers())

  c(
    spanish = spanish_hits + (2 * accent_hits),
    english = english_hits
  )
}

.detect_text_language_internal <- function(texts) {
  scores <- .language_scores(texts)
  spanish_score <- unname(scores["spanish"])
  english_score <- unname(scores["english"])

  if (spanish_score == 0 && english_score == 0) {
    return("unknown")
  }

  if (spanish_score > 0 && english_score > 0 &&
      abs(spanish_score - english_score) <= 1) {
    return("mixed")
  }

  if (english_score >= spanish_score + 2) {
    return("en")
  }

  if (spanish_score >= english_score) {
    return("es")
  }

  "mixed"
}

.resolve_model_spec <- function(model_name, texts) {
  model_name <- .normalize_model_name_input(model_name)

  if (!identical(stringr::str_to_lower(model_name), "auto")) {
    return(list(
      model_name = model_name,
      language = NA_character_,
      selection = "user"
    ))
  }

  language <- .detect_text_language_internal(texts)
  resolved_model <- if (identical(language, "en")) {
    .default_english_model()
  } else {
    .default_multilingual_model()
  }

  list(
    model_name = resolved_model,
    language = language,
    selection = "auto"
  )
}

.attach_model_metadata <- function(x, model_spec) {
  attr(x, "model_name_used") <- model_spec$model_name
  attr(x, "language_detected") <- model_spec$language
  attr(x, "model_selection") <- model_spec$selection
  x
}

.virtualenv_parent_dir <- function(envname) {
  envname <- .validate_single_string(envname, "envname")

  if (stringr::str_detect(envname, "[/\\\\]")) {
    return(dirname(envname))
  }

  reticulate::virtualenv_root()
}

.ensure_virtualenv_parent_dir <- function(envname) {
  parent_dir <- .virtualenv_parent_dir(envname)

  if (dir.exists(parent_dir)) {
    return(invisible(parent_dir))
  }

  success <- dir.create(parent_dir, recursive = TRUE, showWarnings = FALSE)

  if (!success && !dir.exists(parent_dir)) {
    cli::cli_abort(c(
      "The parent directory for the Python virtual environment could not be created.",
      "x" = glue::glue("Path: {parent_dir}"),
      "i" = "Set `RETICULATE_VIRTUALENV_ROOT` or `WORKON_HOME` to a writable directory if needed."
    ))
  }

  invisible(parent_dir)
}

.resolve_label_method <- function(label_method) {
  label_method <- .validate_choice(
    label_method,
    c("auto", "repel", "text", "none"),
    "label_method"
  )

  if (!identical(label_method, "auto")) {
    return(label_method)
  }

  if (requireNamespace("ggrepel", quietly = TRUE)) {
    return("repel")
  }

  "text"
}

.require_plotting_packages <- function(label_method = "text") {
  missing_packages <- c()

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    missing_packages <- c(missing_packages, "ggplot2")
  }

  if (identical(label_method, "repel") &&
      !requireNamespace("ggrepel", quietly = TRUE)) {
    missing_packages <- c(missing_packages, "ggrepel")
  }

  if (length(missing_packages) > 0L) {
    cli::cli_abort(c(
      "Plotting requires additional packages that are not currently installed.",
      "x" = glue::glue("Missing packages: {paste(missing_packages, collapse = ', ')}"),
      "i" = "Install them with `install.packages(c('ggplot2', 'ggrepel'))`."
    ))
  }

  invisible(TRUE)
}

.semantic_color_values <- function(groups, unaligned_label = "no clear alignment") {
  groups <- unique(stats::na.omit(groups))

  if (length(groups) == 0L) {
    return(NULL)
  }

  aligned_groups <- setdiff(groups, unaligned_label)
  palette_values <- stats::setNames(
    grDevices::hcl.colors(
      max(length(aligned_groups), 1L),
      palette = "Dark 3"
    )[seq_along(aligned_groups)],
    aligned_groups
  )

  if (unaligned_label %in% groups) {
    palette_values[unaligned_label] <- "grey55"
  }

  palette_values[groups]
}

.as_numeric_matrix <- function(x, arg = "embeddings") {
  if (is.data.frame(x)) {
    x <- as.matrix(x)
  }

  if (is.atomic(x) && is.null(dim(x))) {
    x <- matrix(x, nrow = 1L)
  }

  if (is.array(x) && length(dim(x)) == 1L) {
    x <- matrix(as.vector(x), nrow = 1L)
  }

  if (!is.matrix(x) && !is.array(x)) {
    cli::cli_abort(glue::glue("`{arg}` must be a numeric matrix or coercible to one."))
  }

  x <- as.matrix(x)

  if (!is.numeric(x)) {
    cli::cli_abort(glue::glue("`{arg}` must be numeric."))
  }

  if (nrow(x) < 1L || ncol(x) < 1L) {
    cli::cli_abort(glue::glue("`{arg}` must contain at least one row and one column."))
  }

  storage.mode(x) <- "double"
  x
}

.current_python_path <- function() {
  if (!reticulate::py_available(initialize = FALSE)) {
    return(NULL)
  }

  normalizePath(
    reticulate::py_config()$python,
    winslash = "/",
    mustWork = FALSE
  )
}

.virtualenv_python_path <- function(envname) {
  envname <- .validate_single_string(envname, "envname")

  if (!reticulate::virtualenv_exists(envname)) {
    return(NULL)
  }

  normalizePath(
    reticulate::virtualenv_python(envname),
    winslash = "/",
    mustWork = FALSE
  )
}

.ensure_active_python_dependencies <- function() {
  missing_modules <- .missing_required_python_modules()

  if (length(missing_modules) == 0L) {
    return(invisible(TRUE))
  }

  active_python <- .current_python_path()
  missing_packages <- unname(.required_python_package_map()[missing_modules])

  cli::cli_inform(c(
    "Python is already initialized; PsyEmbedR will install missing dependencies into the active interpreter for this session.",
    "i" = glue::glue("Active interpreter: {active_python}"),
    "i" = glue::glue("Missing packages: {paste(missing_packages, collapse = ', ')}")
  ))

  tryCatch(
    reticulate::py_install(
      packages = missing_packages,
      pip = TRUE,
      ignore_installed = FALSE
    ),
    error = function(cnd) {
      cli::cli_abort(c(
        "The required Python packages could not be installed into the active interpreter.",
        "x" = conditionMessage(cnd),
        "i" = "Restart the R session and call `ensure_python_deps()` before any other package initializes Python if you prefer to use the dedicated virtual environment."
      ))
    }
  )

  remaining_modules <- .missing_required_python_modules()

  if (length(remaining_modules) > 0L) {
    cli::cli_abort(c(
      "The active Python interpreter is still missing required modules after installation.",
      "x" = glue::glue(
        "Missing modules: {paste(remaining_modules, collapse = ', ')}"
      ),
      "i" = "Restart the R session and call `ensure_python_deps()` before Python is initialized elsewhere."
    ))
  }

  invisible(TRUE)
}

.ensure_python_session_compatible <- function(envname, env_exists = NULL) {
  envname <- .validate_single_string(envname, "envname")

  if (!reticulate::py_available(initialize = FALSE)) {
    return(invisible(list(mode = "requested", python = NULL)))
  }

  active_python <- .current_python_path()

  if (is.null(env_exists)) {
    env_exists <- reticulate::virtualenv_exists(envname)
  }

  target_python <- if (isTRUE(env_exists)) .virtualenv_python_path(envname) else NULL

  if (!is.null(target_python) &&
      identical(tolower(active_python), tolower(target_python))) {
    return(invisible(list(mode = "requested", python = active_python)))
  }

  detail_line <- if (!is.null(target_python)) {
    glue::glue("Requested interpreter: {target_python}")
  } else {
    glue::glue("Requested virtual environment: {envname}")
  }

  cli::cli_inform(c(
    "Python is already initialized in a different interpreter; PsyEmbedR will use the active interpreter in this R session.",
    "i" = glue::glue("Active interpreter: {active_python}"),
    "i" = detail_line,
    "i" = "Restart the R session and call `ensure_python_deps()` first if you want to force the dedicated virtual environment."
  ))

  invisible(list(mode = "active", python = active_python))
}

.set_embedding_dimnames <- function(x, texts, row_prefix = "item") {
  if (!is.null(names(texts)) && !anyDuplicated(names(texts)) && all(names(texts) != "")) {
    rownames(x) <- names(texts)
  } else {
    rownames(x) <- paste0(row_prefix, "_", seq_len(nrow(x)))
  }

  colnames(x) <- paste0("dim_", seq_len(ncol(x)))
  x
}

.pairwise_cosine_similarity <- function(x, y, x_arg = "x", y_arg = "y") {
  x <- .as_numeric_matrix(x, arg = x_arg)
  y <- .as_numeric_matrix(y, arg = y_arg)

  x_norms <- sqrt(rowSums(x ^ 2))
  y_norms <- sqrt(rowSums(y ^ 2))

  if (any(x_norms == 0)) {
    cli::cli_abort(glue::glue("`{x_arg}` contains at least one row with zero norm."))
  }

  if (any(y_norms == 0)) {
    cli::cli_abort(glue::glue("`{y_arg}` contains at least one row with zero norm."))
  }

  similarity <- x %*% t(y)
  similarity <- similarity / (x_norms %o% y_norms)

  if (!is.null(rownames(x))) {
    rownames(similarity) <- rownames(x)
  }

  if (!is.null(rownames(y))) {
    colnames(similarity) <- rownames(y)
  }

  similarity
}

.activate_virtualenv <- function(envname) {
  envname <- .validate_single_string(envname, "envname")
  compatibility <- .ensure_python_session_compatible(envname)

  if (identical(compatibility$mode, "active")) {
    return(invisible(compatibility$python))
  }

  reticulate::use_virtualenv(envname, required = TRUE)
  invisible(envname)
}

.load_sentence_transformer <- function(model_name, envname) {
  model_name <- .validate_single_string(model_name, "model_name")
  envname <- .validate_single_string(envname, "envname")

  ensure_python_deps(envname = envname)
  .activate_virtualenv(envname)

  sentence_transformers <- tryCatch(
    reticulate::import("sentence_transformers", delay_load = FALSE),
    error = function(cnd) {
      cli::cli_abort(c(
        "The `sentence_transformers` module could not be imported.",
        "x" = conditionMessage(cnd),
        "i" = "Run `ensure_python_deps()` and verify that the virtual environment is healthy."
      ))
    }
  )

  tryCatch(
    sentence_transformers$SentenceTransformer(model_name),
    error = function(cnd) {
      cli::cli_abort(c(
        "The requested sentence-transformers model could not be loaded.",
        "x" = conditionMessage(cnd),
        "i" = "Provide a valid local model path or ensure the requested model is available in the local cache."
      ))
    }
  )
}

.encode_with_model <- function(model, texts, normalize = TRUE, row_prefix = "item") {
  texts <- .validate_character_vector(texts, "texts")
  normalize <- .validate_scalar_logical(normalize, "normalize")
  texts_for_python <- reticulate::r_to_py(as.list(unname(texts)))

  embeddings <- tryCatch(
    model$encode(
      texts_for_python,
      convert_to_numpy = TRUE,
      normalize_embeddings = normalize,
      show_progress_bar = FALSE
    ),
    error = function(cnd) {
      cli::cli_abort(c(
        "Sentence embeddings could not be generated.",
        "x" = conditionMessage(cnd)
      ))
    }
  )

  embeddings <- reticulate::py_to_r(embeddings)
  embeddings <- .as_numeric_matrix(embeddings, arg = "embeddings")

  if (nrow(embeddings) != length(texts)) {
    cli::cli_abort(c(
      "The Python model returned an unexpected embedding shape.",
      "x" = glue::glue("Expected {length(texts)} rows, but received {nrow(embeddings)}.")
    ))
  }

  .set_embedding_dimnames(embeddings, texts, row_prefix = row_prefix)
}

.empty_redundancy_result <- function() {
  tibble::tibble(
    item_id_1 = integer(),
    item_text_1 = character(),
    item_id_2 = integer(),
    item_text_2 = character(),
    cosine_similarity = double()
  )
}
