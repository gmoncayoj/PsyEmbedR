\name{detect_text_language}
\alias{detect_text_language}
\title{Detect the dominant language of a text set}
\usage{
detect_text_language(texts)
}
\arguments{
  \item{texts}{Character vector containing the texts to inspect.}
}
\value{
A single character value indicating the detected language:
\code{"es"}, \code{"en"}, \code{"mixed"}, or \code{"unknown"}.
}
\description{
Performs a lightweight local heuristic over the supplied texts and
returns one of \code{"es"}, \code{"en"}, \code{"mixed"}, or
\code{"unknown"}. The heuristic is intended to support model selection
for short psychometric items and definitions without relying on external
services.
}
\examples{
detect_text_language(c(
  "Me adapto cuando cambian las circunstancias.",
  "Mi familia me brinda apoyo."
))

detect_text_language(c(
  "I adapt when circumstances change.",
  "My family gives me support."
))
}
