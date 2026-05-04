\name{plot_semantic_map}
\alias{plot_semantic_map}
\title{Plot a two-dimensional semantic map of items}
\usage{
plot_semantic_map(
  items,
  definitions = NULL,
  expected_dimension = NULL,
  model_name = "auto",
  envname = "r-psyembedr",
  method = "mds",
  color_by = "none",
  min_similarity = 0.2,
  unaligned_label = "no clear alignment",
  label_width = 30,
  label_method = "auto",
  label_size = 3,
  label_seed = 123,
  point_color = "steelblue",
  point_size = 3,
  title = "Semantic Space 2D"
)
}
\arguments{
  \item{items}{Character vector with one item text per element.}

  \item{definitions}{Optional named character vector with theoretical
  definitions. Required when \code{color_by = "inferred"}.}

  \item{expected_dimension}{Optional character vector with the expected
  dimension for each item. Required when
  \code{color_by = "expected"}.}

  \item{model_name}{Sentence-transformers model identifier, local path,
  or \code{"auto"} to choose a model heuristically from the item text
  language.}

  \item{envname}{Name of the Python virtual environment to activate.}

  \item{method}{Projection method. Use \code{"mds"} to project cosine
  distances or \code{"pca"} to project the embedding matrix directly.}

  \item{color_by}{Coloring strategy. Use \code{"none"} for a single
  color, \code{"inferred"} to color by semantic dimension inferred from
  \code{definitions}, or \code{"expected"} to color by
  \code{expected_dimension}.}

  \item{min_similarity}{Minimum similarity used when
  \code{color_by = "inferred"}.}

  \item{unaligned_label}{Label used for low-similarity inferred items.}

  \item{label_width}{Maximum label width passed to
  \code{stringr::str_wrap()}.}

  \item{label_method}{Label drawing strategy. \code{"auto"} uses
  \code{ggrepel::geom_text_repel()} when available and falls back to
  \code{ggplot2::geom_text()}. \code{"repel"}, \code{"text"}, and
  \code{"none"} force a specific behavior.}

  \item{label_size}{Label size used in the plot.}

  \item{label_seed}{Random seed used by \code{ggrepel} when repelled
  labels are active.}

  \item{point_color}{Point color used in the plot.}

  \item{point_size}{Point size used in the plot.}

  \item{title}{Plot title.}
}
\value{
A \code{ggplot2} object. The returned object also carries attributes
\code{semantic_coordinates}, \code{semantic_cosine_matrix},
\code{semantic_groups}, \code{model_name_used}, and
\code{language_detected}.
}
\description{
Builds a two-dimensional visualization of item locations from local
sentence embeddings. By default, the function computes the cosine
similarity matrix and projects the resulting cosine distances with
classical multidimensional scaling (MDS). A PCA projection of the
embeddings can also be requested.
}
\examples{
\dontrun{
ensure_python_deps()

items <- c(
  "Me recupero rápidamente después de una situación difícil.",
  "Puedo adaptarme cuando las circunstancias cambian.",
  "Mi familia me brinda apoyo cuando lo necesito."
)

plot_semantic_map(items)
}
}
