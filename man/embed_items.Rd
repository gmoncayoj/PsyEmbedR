\name{embed_items}
\alias{embed_items}
\title{Generate sentence embeddings for item texts}
\usage{
embed_items(
  items,
  model_name = "auto",
  envname = "r-psyembedr",
  normalize = TRUE
)
}
\arguments{
  \item{items}{Character vector with one item text per element.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the text
  language. When \code{"auto"} is used, the package selects
  \code{"sentence-transformers/all-mpnet-base-v2"} for English-only
  text and
  \code{"sentence-transformers/paraphrase-multilingual-mpnet-base-v2"}
  otherwise.}

  \item{envname}{Name of the Python virtual environment to activate.}

  \item{normalize}{Logical scalar. If \code{TRUE}, embeddings are L2
  normalized by the Python model before being returned.}
}
\value{
A numeric matrix with one row per input item and one column per
embedding dimension.
}
\description{
Encodes a character vector of item texts with a local
\code{sentence-transformers} model accessed from R through
\code{reticulate}.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "I adapt quickly when plans change.",
  "I recover well after difficult situations."
)

emb <- embed_items(items)
dim(emb)
}
}
