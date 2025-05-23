% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/factor.R
\name{emend_fct_match}
\alias{emend_fct_match}
\title{Match input factor to specified levels.}
\usage{
emend_fct_match(.f, levels = NULL, chat = get_default_chat())
}
\arguments{
\item{.f}{A factor.}

\item{levels}{The levels of the factor}

\item{chat}{A chat object defined by ellmer.}
}
\value{
A factor with levels matching the provided \code{levels} argument.
}
\description{
Match input factor to specified levels.
}
\examples{
\donttest{
chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
emend_fct_match(messy$country, levels = c("UK", "USA", "Canada", "Australia", "NZ"), chat = chat)
}

}
