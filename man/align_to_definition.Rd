\name{align_to_definition}
\alias{align_to_definition}
\title{Align items to named theoretical definitions}
\usage{
align_to_definition(
  items,
  definitions,
  model_name = "auto",
  envname = "r-psyembedr"
)
}
\arguments{
  \item{items}{Character vector with one item text per element.}

  \item{definitions}{Named character vector in which names identify the
  theoretical dimensions and values contain their textual definitions.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the combined
  text language of \code{items} and \code{definitions}.}

  \item{envname}{Name of the Python virtual environment to activate.}
}
\value{
A tibble in long format with the columns \code{item_id},
\code{item_text}, \code{definition}, \code{cosine_similarity},
\code{best_match}, and \code{best_similarity}.
}
\description{
Computes semantic similarity between item texts and a named vector of
theoretical definitions, then reports both the full similarity table and
the best matching definition for each item.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "I notice quickly when my environment changes.",
  "I adjust my behavior to meet changing demands."
)

definitions <- c(
  ecological = "Sensitivity to cues and affordances in the environment.",
  adaptive = "Capacity to change behavior effectively in response to demands."
)

align_to_definition(items, definitions)
}
}
