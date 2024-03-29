% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/questionnaire_helpers.R
\name{button_next}
\alias{button_next}
\alias{button_previous}
\title{Go to the next page}
\usage{
button_next(label = "Weiter")

button_previous(label = "Zurück")
}
\arguments{
\item{label}{What label the button should have.}
}
\value{
shiny Action Button
}
\description{
Buttons to navigate between pages.
}
\section{Functions}{
\itemize{
\item \code{button_previous()}: Go to the previous page

}}
\examples{
\dontshow{data.table::setDTthreads(1)}

\dontrun{
very_simple_page <- new_page(
  page_id = "example",
  render = function(session, run_before_output, input, output, ...) {
    list(
      shiny::tags$h1("My test page"),
      button_previous(),
      button_next()
    )
  }
)
}
}
\seealso{
\code{\link[=new_page]{new_page()}}
}
