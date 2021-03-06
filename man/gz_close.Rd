% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{gz_close}
\alias{gz_close}
\title{Close the gz file}
\usage{
gz_close(gzfile)
}
\arguments{
\item{gzfile}{file handle}
}
\description{
Close the gz file
}
\note{
if you want to properly flush the buffers and correctly terminate a gzip stream
  then you \emph{must} call \code{gz_flush()} before closing the file.
}

