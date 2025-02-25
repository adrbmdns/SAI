% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date.R
\name{sai_clean_date}
\alias{sai_clean_date}
\title{Standardise date format}
\usage{
sai_clean_date(dates_vector, input_format = "DD/MM/YYYY", copy = FALSE, ...)
}
\arguments{
\item{dates_vector}{A character vector that is assumed to be dates.}

\item{input_format}{A character value to specify input date format.}

\item{...}{Extra options for the large language model.}
}
\description{
This function standardise inconsistent date formats.
}
\examples{
x <- c("12/05/2024", "11/15/2024", "02/25/2024")
sai_clean_date(x, input_format = "MM/DD/YYYY")




}
