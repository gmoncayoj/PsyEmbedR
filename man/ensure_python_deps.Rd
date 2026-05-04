\name{ensure_python_deps}
\alias{ensure_python_deps}
\title{Ensure local Python dependencies for PsyEmbedR}
\usage{
ensure_python_deps(envname = "r-psyembedr", python = NULL)
}
\arguments{
  \item{envname}{Name of the virtual environment managed by
  \code{reticulate}.}

  \item{python}{Optional path to a Python interpreter to use when the
  environment is created for the first time.}
}
\value{
Invisibly returns a list with the virtual environment name, the active
Python interpreter, and the Python modules checked by the function.
}
\description{
Verifies that the requested Python virtual environment exists, creates
it if needed, installs the required Python packages, activates the
environment through \code{reticulate}, and checks that
\code{sentence_transformers} is available. When the parent directory of
the target virtual environment does not exist yet, \code{PsyEmbedR}
creates it first to make first-run setup more robust across machines.
If Python has already been initialized elsewhere in the current R
session, the function reuses the active interpreter and attempts to
install missing dependencies there.
}
\examples{
\dontrun{
ensure_python_deps()
ensure_python_deps(envname = "r-psyembedr", python = "C:/Python311/python.exe")
}
}
