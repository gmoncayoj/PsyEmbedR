\name{cosine_matrix}
\alias{cosine_matrix}
\title{Compute a cosine similarity matrix}
\usage{
cosine_matrix(embeddings)
}
\arguments{
  \item{embeddings}{Numeric matrix with one observation per row.}
}
\value{
A symmetric numeric matrix whose entries are row-wise cosine
similarities.
}
\description{
Computes the cosine similarity between all rows of a numeric embedding
matrix.
}
\examples{
emb <- rbind(
  c(1, 0),
  c(0, 1),
  c(1, 1)
)

cosine_matrix(emb)
}
