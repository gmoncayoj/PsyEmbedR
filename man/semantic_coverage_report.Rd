\name{semantic_coverage_report}
\alias{semantic_coverage_report}
\title{Summarize semantic coverage across theoretical dimensions}
\usage{
semantic_coverage_report(
  items,
  definitions,
  expected_dimension = NULL,
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

  \item{expected_dimension}{Optional character vector with the expected
  dimension for each item, in the same order as \code{items}.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the combined
  text language of \code{items} and \code{definitions}.}

  \item{envname}{Name of the Python virtual environment to activate.}

  \item{min_similarity}{Minimum cosine similarity required to treat the
  best match as a usable semantic assignment in the summary.}

  \item{unaligned_label}{Label assigned to items that do not reach
  \code{min_similarity}.}
}
\value{
A list with components:
\describe{
  \item{\code{alignment_long}}{Long-format tibble with every
  item-definition similarity.}
  \item{\code{best_alignment}}{One-row-per-item tibble with the best
  semantic match and its threshold status.}
  \item{\code{summary_by_dimension}}{Summary tibble with counts and
  proportions by semantic dimension.}
  \item{\code{classification_summary}}{One-row tibble comparing expected
  and semantic classifications, or \code{NULL} if
  \code{expected_dimension} is not supplied.}
  \item{\code{misaligned_items}}{Tibble of items whose expected and
  semantic classifications differ, or \code{NULL} if
  \code{expected_dimension} is not supplied.}
}
}
\description{
Uses \code{align_to_definition()} to summarize how many items are
closest to each theoretical definition. When an expected dimension is
provided, the function also compares expected and semantic
classifications and identifies misaligned items.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "I adapt my plans when new demands appear.",
  "I quickly detect relevant changes in my environment.",
  "I recover my focus after setbacks."
)

definitions <- c(
  adaptive = "Flexible behavior change in response to situational demands.",
  ecological = "Detection of relevant cues in the surrounding environment.",
  resilient = "Recovery of effective functioning after challenge or stress."
)

semantic_coverage_report(
  items = items,
  definitions = definitions,
  expected_dimension = c("adaptive", "ecological", "resilient")
)
}
}
