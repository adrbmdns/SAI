% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date.R
\name{emend_clean_date}
\alias{emend_clean_date}
\title{Standardise date format}
\usage{
emend_clean_date(dates_vector, chat = get_default_chat())
}
\arguments{
\item{dates_vector}{A character vector that is assumed to be dates.}

\item{chat}{A chat object defined by ellmer.}
}
\value{
A vector of Date objects.
}
\description{
This function standardise inconsistent date formats.
}
\examples{
\donttest{
x <- c("16/02/1997", "20 November 2024", "24 Mar 2022", "2000-01-01", "Jason", 
       "Dec 25, 2030", "11/05/2024", "March 10, 1999")
chat <- ellmer::chat_ollama(model = "llama3.1:8b", seed = 0, echo = "none")
emend_clean_date(x, chat = chat)
}

}
