\name{infer_dimensions}
\alias{infer_dimensions}
\title{Infer the most likely definition for each item}
\usage{
infer_dimensions(
  items,
  definitions,
  model_name = "auto",
  envname = "r-psyembedr",
  min_similarity = 0.2,
  unaligned_label = "no clear alignment"
)
}
\arguments{
  \item{items}{Character vector with one item text per element.}

  \item{definitions}{Named character vector in which names identify the
  theoretical dimensions and values contain their textual definitions.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the text
  language.}

  \item{envname}{Name of the Python virtual environment to activate.}

  \item{min_similarity}{Minimum cosine similarity required to treat the
  best match as a usable semantic assignment. Values below this
  threshold are flagged as lacking a clear semantic alignment.}

  \item{unaligned_label}{Label assigned when
  \code{predicted_similarity} is below \code{min_similarity}.}
}
\value{
A tibble with the columns \code{item_id}, \code{item_text},
\code{nearest_definition}, \code{predicted_dimension},
\code{predicted_similarity}, \code{meets_similarity_threshold}, and
\code{alignment_note}.
}
\description{
Provides a one-row-per-item semantic classification based on the highest
cosine similarity between each item and the supplied theoretical
definitions.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "Me adapto cuando cambian las circunstancias.",
  "Mi familia me brinda apoyo cuando lo necesito."
)

definitions <- c(
  adaptive = "Capacidad de ajustarse flexiblemente a cambios y exigencias.",
  ecological = "Recursos familiares y sociales que facilitan el afrontamiento."
)

infer_dimensions(items, definitions)
}
}
