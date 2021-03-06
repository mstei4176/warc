#' Read a WARC entry from a WARC file
#'
#' Given the path to a WARC file (compressed or uncompressed) and the start
#' position of the WARC record, this function will produce an R object from the
#' WARC record.
#'
#' WARC \code{warinfo} objects are returned classed both \code{warc} and
#' \code{info}.
#'
#' WARC \code{response} objects are returned classed both \code{warc} and
#' \code{httr::response} and the standard \code{httr} content functions
#' will work with the object.
#'
#' WARC \code{request} objects are returned classed both \code{warc} and
#' \code{httr::request}.
#'
#' @param path path to WARC file
#' @param start starting offset of WARC record
#' @export
#' @note \code{warcinfo}, \code{request} and \code{response} objects are currently
#'   supported.
#' @examples \dontrun{
#' cdx <- read_cdx(system.file("extdata", "20160901.cdx", package="warc"))
#' i <- 1
#' path <- file.path(cdx$warc_path[i], cdx$file_name[i])
#' start <- cdx$compressed_arc_file_offset[i]
#'
#' (read_warc_entry(path, start))
#' }
read_warc_entry <- function(path, start, compressed=grepl(".gz$", path)) {

  path <- path.expand(path)

  if (compressed) {

    buffer <- sgzip_inflate_from_pos(path, start)

    if (is.null(buffer$result)) {
      buffer <- rwc_the_hard_way(path, start)
    } else {
      buffer <- buffer$result
    }

  } else { # shld prbly refactor this since I built gz-tools

    fil <- file(path, "rb")
    seek(fil, start)

    # get content length
    cl <- 0
    repeat {
      line <- readLines(fil, 1)
      if (suppressWarnings(grepl("^Content-Length: ", line))) {
        cl <- as.numeric(stri_split_fixed(trimws(line), ": ", 2)[[1]][2])
        break
      }
    }

    # find end of WARC header
    repeat {
      line <- trimws(readLines(fil, 1))
      if (line == "") break
    }

    # go to end of record
    seek(fil, cl+2, "current")
    pos <- seek(fil)

    seek(fil, start)
    buffer <- readBin(fil, "raw", pos-start)
    close(fil)

  }

  process_entry(buffer)

}

rwc_the_hard_way  <- function(path, start) {

  message("Using the hard way")
  message(start)

  w_pos <- start

  gzf <- gz_open(wf, "read")
  gz_fseek(gzf, w_pos, "start") # seek to record start

  w_rec <- c() # header is small enough that we don't need to reserve space

  repeat { # read lines until we get to end of WARC header
    line <- gz_gets(gzf)
    if (line == "\r\n") break;
    w_rec <- c(w_rec, line)
  }

  w_ofs <- gz_offset(gzf) # get position of the start of content

  gz_close(gzf)

  c_len <- suppressWarnings(grep("^Content-Length: ", w_rec, value=TRUE))

  if (length(c_len) > 0) {

    c_len <- as.numeric(stri_match_first_regex(c_len, " ([[:digit:]]+)")[,2])

    gzf <- gz_open(wf, "read")
    gz_fseek(gzf, w_pos, "start")

    buffer <- gz_read_raw(gzf, sum(purrr::map_int(w_rec, nchar)) + 2 + c_len + 4)

    gz_close(gzf)

    buffer

  } else {
    stop("WARC record is invalid. No 'Content-Length:' WARC header found.", call.=FALSE)
  }

}
