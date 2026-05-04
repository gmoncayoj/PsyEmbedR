#' Plot a two-dimensional semantic map of items
#'
#' Builds a two-dimensional visualization of item locations from local
#' sentence embeddings. By default, the function computes the cosine
#' similarity matrix and projects the resulting cosine distances with
#' classical multidimensional scaling (MDS). A PCA projection of the
#' embeddings can also be requested.
#'
#' @param items Character vector with one item text per element.
#' @param definitions Optional named character vector with theoretical
#'   definitions. Required when `color_by = "inferred"`.
#' @param expected_dimension Optional character vector with the expected
#'   dimension for each item. Required when `color_by = "expected"`.
#' @param model_name Sentence-transformers model identifier, local path,
#'   or `"auto"` to choose a model heuristically from the item text
#'   language.
#' @param envname Name of the Python virtual environment to activate.
#' @param method Projection method. Use `"mds"` to project cosine
#'   distances or `"pca"` to project the embedding matrix directly.
#' @param color_by Coloring strategy. Use `"none"` for a single color,
#'   `"inferred"` to color by semantic dimension inferred from
#'   `definitions`, or `"expected"` to color by `expected_dimension`.
#' @param min_similarity Minimum similarity used when
#'   `color_by = "inferred"`.
#' @param unaligned_label Label used for low-similarity inferred items.
#' @param label_width Maximum label width passed to `stringr::str_wrap()`.
#' @param label_method Label drawing strategy. `"auto"` uses
#'   `ggrepel::geom_text_repel()` when available and falls back to
#'   `ggplot2::geom_text()`. `"repel"`, `"text"`, and `"none"` force a
#'   specific behavior.
#' @param label_size Label size used in the plot.
#' @param label_seed Random seed used by `ggrepel` when repelled labels
#'   are active.
#' @param point_color Point color used in the plot.
#' @param point_size Point size used in the plot.
#' @param title Plot title.
#'
#' @return A `ggplot2` object. The returned object also carries
#'   attributes `semantic_coordinates`, `semantic_cosine_matrix`,
#'   `semantic_groups`, `model_name_used`, and `language_detected`.
#' @export
#'
#' @examples
#' \dontrun{
#' ensure_python_deps()
#'
#' items <- c(
#'   "Me recupero rápidamente después de una situación difícil.",
#'   "Puedo adaptarme cuando las circunstancias cambian.",
#'   "Mi familia me brinda apoyo cuando lo necesito."
#' )
#'
#' definitions <- c(
#'   adaptive = "Capacidad de ajustarse flexiblemente a cambios y exigencias.",
#'   ecological = "Recursos familiares y sociales que facilitan el afrontamiento."
#' )
#'
#' plot_semantic_map(items)
#' plot_semantic_map(items, definitions = definitions, color_by = "inferred")
#' }
plot_semantic_map <- function(
    items,
    definitions = NULL,
    expected_dimension = NULL,
    model_name = "auto",
    envname = "r-psyembedr",
    method = "mds",
    color_by = "none",
    min_similarity = 0.20,
    unaligned_label = "no clear alignment",
    label_width = 30,
    label_method = "auto",
    label_size = 3,
    label_seed = 123,
    point_color = "steelblue",
    point_size = 3,
    title = "Semantic Space 2D") {
  items <- .validate_character_vector(items, "items")
  definitions <- .validate_optional_named_definitions(definitions)
  envname <- .validate_single_string(envname, "envname")
  method <- .validate_choice(method, c("mds", "pca"), "method")
  color_by <- .validate_choice(color_by, c("none", "inferred", "expected"), "color_by")
  min_similarity <- .validate_threshold(min_similarity)
  unaligned_label <- .validate_single_string(unaligned_label, "unaligned_label")
  label_width <- .validate_positive_number(label_width, "label_width")
  label_method <- .resolve_label_method(label_method)
  label_size <- .validate_positive_number(label_size, "label_size")
  label_seed <- .validate_positive_number(label_seed, "label_seed")
  point_color <- .validate_single_string(point_color, "point_color")
  point_size <- .validate_positive_number(point_size, "point_size")
  title <- .validate_single_string(title, "title")

  if (identical(color_by, "inferred") && is.null(definitions)) {
    cli::cli_abort("`definitions` must be supplied when `color_by = 'inferred'`.")
  }

  if (identical(color_by, "expected") && is.null(expected_dimension)) {
    cli::cli_abort("`expected_dimension` must be supplied when `color_by = 'expected'`.")
  }

  if (!is.null(expected_dimension)) {
    if (is.null(definitions)) {
      expected_dimension <- .validate_expected_dimension_any(
        expected_dimension = expected_dimension,
        n_items = length(items)
      )
    } else {
      expected_dimension <- .validate_expected_dimension(
        expected_dimension = expected_dimension,
        definitions = definitions,
        n_items = length(items)
      )
    }
  }

  .require_plotting_packages(label_method = label_method)

  embeddings <- embed_items(
    items = items,
    model_name = model_name,
    envname = envname,
    normalize = TRUE
  )

  similarity <- cosine_matrix(embeddings)
  coordinates <- .semantic_projection(
    embeddings = embeddings,
    similarity = similarity,
    method = method
  )

  plot_data <- tibble::tibble(
    item_id = seq_along(items),
    item_text = items,
    item_label = stringr::str_wrap(items, width = label_width),
    x = coordinates[, 1],
    y = coordinates[, 2]
  )

  group_data <- .semantic_group_data(
    items = items,
    definitions = definitions,
    expected_dimension = expected_dimension,
    color_by = color_by,
    model_name = model_name,
    envname = envname,
    min_similarity = min_similarity,
    unaligned_label = unaligned_label
  )

  plot_data <- dplyr::left_join(plot_data, group_data, by = c("item_id", "item_text"))

  axis_labels <- .semantic_axis_labels(
    embeddings = embeddings,
    method = method
  )

  has_groups <- !identical(color_by, "none")
  legend_title <- if (identical(color_by, "inferred")) {
    "Inferred dimension"
  } else if (identical(color_by, "expected")) {
    "Expected dimension"
  } else {
    "Group"
  }

  plot <- if (has_groups) {
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(
        x = x,
        y = y,
        label = item_label,
        colour = semantic_group
      )
    ) +
      ggplot2::geom_point(size = point_size)
  } else {
    ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = x, y = y, label = item_label)
    ) +
      ggplot2::geom_point(color = point_color, size = point_size)
  }

  if (identical(label_method, "repel")) {
    plot <- plot +
      ggrepel::geom_text_repel(
        color = "black",
        size = label_size,
        seed = as.integer(label_seed),
        max.overlaps = Inf,
        box.padding = 0.40,
        point.padding = 0.25,
        force = 1,
        force_pull = 0.15,
        min.segment.length = 0,
        segment.color = "grey55"
      )
  } else if (identical(label_method, "text")) {
    plot <- plot +
      ggplot2::geom_text(
        color = "black",
        size = label_size,
        vjust = -0.7,
        check_overlap = TRUE
      )
  }

  plot <- plot +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(mult = c(0.18, 0.28))
    ) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.12, 0.12))
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.margin = ggplot2::margin(10, 50, 10, 10)
    ) +
    ggplot2::labs(
      title = title,
      subtitle = glue::glue(
        "Method: {toupper(method)} | Model: {attr(embeddings, 'model_name_used')} | Labels: {label_method} | Color: {color_by}"
      ),
      x = axis_labels$x,
      y = axis_labels$y
    )

  if (has_groups) {
    color_values <- .semantic_color_values(
      groups = plot_data$semantic_group,
      unaligned_label = unaligned_label
    )

    plot <- plot +
      ggplot2::scale_color_manual(
        values = color_values,
        drop = FALSE,
        name = legend_title
      )
  }

  attr(plot, "semantic_coordinates") <- plot_data
  attr(plot, "semantic_cosine_matrix") <- similarity
  attr(plot, "semantic_groups") <- group_data
  attr(plot, "model_name_used") <- attr(embeddings, "model_name_used")
  attr(plot, "language_detected") <- attr(embeddings, "language_detected")
  attr(plot, "model_selection") <- attr(embeddings, "model_selection")

  plot
}

.semantic_group_data <- function(
    items,
    definitions,
    expected_dimension,
    color_by,
    model_name,
    envname,
    min_similarity,
    unaligned_label) {
  if (identical(color_by, "none")) {
    return(tibble::tibble(
      item_id = seq_along(items),
      item_text = items,
      semantic_group = NA_character_,
      group_source = NA_character_
    ))
  }

  if (identical(color_by, "expected")) {
    return(tibble::tibble(
      item_id = seq_along(items),
      item_text = items,
      semantic_group = expected_dimension,
      group_source = "expected"
    ))
  }

  inferred <- infer_dimensions(
    items = items,
    definitions = definitions,
    model_name = model_name,
    envname = envname,
    min_similarity = min_similarity,
    unaligned_label = unaligned_label
  )

  tibble::tibble(
    item_id = inferred$item_id,
    item_text = inferred$item_text,
    semantic_group = inferred$predicted_dimension,
    group_source = "inferred"
  )
}

.semantic_projection <- function(embeddings, similarity, method) {
  method <- .validate_choice(method, c("mds", "pca"), "method")
  n_items <- nrow(similarity)

  if (identical(method, "pca")) {
    if (n_items == 1L) {
      coordinates <- matrix(c(0, 0), nrow = 1L, dimnames = list(NULL, c("x", "y")))
      return(coordinates)
    }

    pca <- stats::prcomp(embeddings, center = TRUE, scale. = FALSE)
    coordinates <- pca$x[, seq_len(min(2L, ncol(pca$x))), drop = FALSE]

    if (ncol(coordinates) == 1L) {
      coordinates <- cbind(coordinates, 0)
    }

    colnames(coordinates) <- c("x", "y")
    return(coordinates)
  }

  if (n_items == 1L) {
    coordinates <- matrix(c(0, 0), nrow = 1L, dimnames = list(NULL, c("x", "y")))
    return(coordinates)
  }

  distance_matrix <- 1 - similarity
  distance_matrix <- pmax(distance_matrix, 0)
  diag(distance_matrix) <- 0

  if (n_items == 2L) {
    half_distance <- distance_matrix[1, 2] / 2
    coordinates <- rbind(
      c(-half_distance, 0),
      c(half_distance, 0)
    )
    colnames(coordinates) <- c("x", "y")
    return(coordinates)
  }

  if (all(distance_matrix == 0)) {
    coordinates <- matrix(0, nrow = n_items, ncol = 2L)
    colnames(coordinates) <- c("x", "y")
    return(coordinates)
  }

  coordinates <- tryCatch(
    stats::cmdscale(stats::as.dist(distance_matrix), k = 2),
    error = function(cnd) {
      cli::cli_abort(c(
        "The cosine-distance projection could not be computed.",
        "x" = conditionMessage(cnd)
      ))
    }
  )

  coordinates <- as.matrix(coordinates)

  if (ncol(coordinates) == 1L) {
    coordinates <- cbind(coordinates, 0)
  }

  colnames(coordinates) <- c("x", "y")
  coordinates
}

.semantic_axis_labels <- function(embeddings, method) {
  if (identical(method, "pca")) {
    if (nrow(embeddings) == 1L) {
      return(list(
        x = "PC1",
        y = "PC2"
      ))
    }

    pca <- stats::prcomp(embeddings, center = TRUE, scale. = FALSE)
    variance <- (pca$sdev ^ 2) / sum(pca$sdev ^ 2)
    variance <- variance[seq_len(min(2L, length(variance)))]

    if (length(variance) == 1L) {
      variance <- c(variance, 0)
    }

    return(list(
      x = glue::glue("PC1 ({round(variance[1] * 100, 1)}%)"),
      y = glue::glue("PC2 ({round(variance[2] * 100, 1)}%)")
    ))
  }

  list(
    x = "Dimension 1",
    y = "Dimension 2"
  )
}
