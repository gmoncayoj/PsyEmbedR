\name{flag_redundancy}
\alias{flag_redundancy}
\title{Flag semantically redundant item pairs}
\usage{
flag_redundancy(
  items,
  threshold = 0.85,
  model_name = "auto",
  envname = "r-psyembedr"
)
}
\arguments{
  \item{items}{Character vector with one item text per element.}

  \item{threshold}{Numeric scalar in the interval \code{[0, 1]}. Pairs
  with cosine similarity greater than or equal to this value are
  flagged.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the item text
  language.}

  \item{envname}{Name of the Python virtual environment to activate.}
}
\value{
A tibble sorted from highest to lowest cosine similarity, with the
columns \code{item_id_1}, \code{item_text_1}, \code{item_id_2},
\code{item_text_2}, and \code{cosine_similarity}.
}
\description{
Generates embeddings for a set of items, computes the cosine similarity
matrix, and returns item pairs whose similarity meets or exceeds a
chosen threshold.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "I adapt well to changing conditions.",
  "I adjust well when conditions change.",
  "I notice details in my surroundings."
)

flag_redundancy(items, threshold = 0.85)
}
}
