#' PsyEmbedR: Local semantic auditing for psychometric items
#'
#' `PsyEmbedR` provides a local workflow for the preliminary semantic
#' auditing of psychometric item banks. It uses Python through
#' `reticulate` together with `sentence-transformers` to create sentence
#' embeddings, compute cosine similarities, align items to theoretical
#' definitions, detect semantic redundancy, visualize item maps, and
#' summarize semantic coverage by dimension.
#'
#' The package does not rely on external AI APIs. Model inference is
#' performed locally once the Python environment and the selected
#' sentence-transformers model are available on the machine.
#'
#' @keywords internal
"_PACKAGE"
