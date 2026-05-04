\name{PsyEmbedR-package}
\alias{PsyEmbedR}
\alias{PsyEmbedR-package}
\docType{package}
\title{PsyEmbedR: Local semantic auditing for psychometric items}
\description{
Provides a local workflow for the preliminary semantic auditing of
psychometric item banks.
}
\details{
The package integrates R with Python through \code{reticulate} and uses
\code{sentence-transformers} to create sentence embeddings, compute
cosine similarities, align items to theoretical definitions, detect
semantic redundancy, visualize item maps, and summarize semantic
coverage by dimension.

The package does not depend on external AI APIs. Model inference is
performed locally once the Python environment and the selected
sentence-transformers model are available on the machine.
}
\keyword{internal}
