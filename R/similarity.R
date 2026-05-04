#' Compute a cosine similarity matrix
#'
#' Computes the cosine similarity between all rows of a numeric embedding
#' matrix.
#'
#' @param embeddings Numeric matrix with one observation per row.
#'
#' @return A symmetric numeric matrix whose entries are row-wise cosine
#'   similarities.
#' @export
#'
#' @examples
#' emb <- rbind(
#'   c(1, 0),
#'   c(0, 1),
#'   c(1, 1)
#' )
#'
#' cosine_matrix(emb)
cosine_matrix <- function(embeddings) {
  embeddings <- .as_numeric_matrix(embeddings, arg = "embeddings")
  similarity <- .pairwise_cosine_similarity(
    embeddings,
    embeddings,
    x_arg = "embeddings",
    y_arg = "embeddings"
  )

  similarity <- (similarity + t(similarity)) / 2
  diag(similarity) <- 1
  similarity
}
