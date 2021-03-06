% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{gzip_inflate_from_pos}
\alias{gzip_inflate_from_pos}
\title{Inflate a gzip stream from a file}
\usage{
gzip_inflate_from_pos(path, raw_stream_pos)
}
\arguments{
\item{path}{path to gzip individual stream compressed WARC file}

\item{raw_stream_pos}{position in the raw file at \code{path} (not the "gzip
stream position")}
}
\description{
Given a gzip file that was built with concatenated individual gzip streams,
this function will expand the contents of the stream into a \code{raw} vector
and return it.
}
\note{
Since this is working with compressed files, the memory size of the returned
  value may be quite large.
}

