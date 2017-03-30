# timeline-reader.R: Decode binary timeline into data frame.

library(dplyr)
library(stringr)
library(bit64)

# Read a timeline file into a data frame.
read_timeline <- function(filename) {
  tl <- read_binary_timeline(filename)
  tl$numa <- as.factor(tl$numa)
  tl$core <- as.factor(tl$core)
  tl$unixtime <- calculate_unixtime(tl)
  tl$cycles <- calculate_cycles(tl)
  # Sort entries by unix time. Should roughly take care of log wrap-around.
  # See FIXME comment in unixtime() though.
#  tl <- arrange(tl, unixtime)
  tl
}

# Read a timeline file into a tibble.
read_binary_timeline <- function(filename) {
  f <- file(filename, "rb")
  # Read fields
  magic <- readBin(f, raw(), n=8, endian="little")
  version <- readBin(f, "integer", n=2, size=2, endian="little")
  log_bytes <- readBin(f, "integer", n=1, size=4, endian="little")
  strings_bytes <- readBin(f, "integer", n=1, size=4, endian="little")
  # Check compat
  if (!all(magic == c(0x01, 0x00, 0x1d, 0x44, 0x23, 0x72, 0xff, 0xa3))) {
    stop("bad magic number")
  }
  if (version[1] != 2 & version[1] != 3) {
    stop("unrecognized major version")
  }
  seek(f, 64)
  entries <- readBin(f, "double", n=log_bytes/8, size=8, endian="little")
  elem0 = seq(1, log_bytes/8, 64/8)
  # Tricky: Second element is integer on disk but double in R
  tmp <- entries[elem0+1]
  class(tmp) <- "integer64"
  entries[elem0+1] <- as.numeric(tmp)
  tl <- tibble(tsc = entries[elem0],
               msgid = bitwAnd(entries[elem0+1], 0xFFFF),
               core = bitwAnd(bitwShiftR(entries[elem0+1], 16), 0xF),
               numa = bitwShiftR(entries[elem0+1], 24),
               arg0 = entries[elem0+2],
               arg1 = entries[elem0+3],
               arg2 = entries[elem0+4],
               arg3 = entries[elem0+5],
               arg4 = entries[elem0+6],
               arg5 = entries[elem0+7])
  tl <- na.omit(tl)
  # Read strings
  stringtable <- character(strings_bytes/16) # dense array
  start <- 64+log_bytes
  seek(f, start)
  repeat {
    id <- 1+(seek(f)-start)/16
    s <- readBin(f, "character")
    if (s == "") break;
    stringtable[id] <- s
    seek(f, ceiling(seek(f)/16) * 16) # seek to 16-byte alignment
  }
  # Decode string messages
  messages <- tibble(msgid = 0:(length(stringtable)-1), message = stringtable) %>%
    filter(message != "") %>%
    mutate(summary = str_extract(message, "^[^\n]+"),
           level = as.integer(str_extract(summary, "^[0-9]")),
           event = gsub("^[0-9]\\|([^:]+):.*", "\\1", summary))
  # Combine messages with events
  left_join(tl, messages, by="msgid")
}

# Calculate unix timestamps for each entry.
calculate_unixtime <- function(tl) {
  times <- filter(tl, grepl("got_monotonic_time", event))

  # FIXME: Make sure the delta is taken between two timestamps from
  # the _same CPU core_. If we take the delta between two timestamps
  # whose TSCs are not synchronized (e.g. different NUMA nodes) then
  # we will misestimate the clock speed (maybe even negative...)
  
  if (length(times) < 2) {
    stop("could not calculate unix time: need two timestamps to compare.")  
  } else {

    # Calculate GHz (cycles per nanosecond) from timestamp deltas.
    GHz <- (max(times$tsc)-min(times$tsc)) / (max(times$arg0)-min(times$arg0))
    # Pick an epoch (any will do)
    reftsc <- last(times$tsc)
    reftime <- last(times$arg0)
    # Function from cycles to unix nanoseconds
    unixtime <- function(tsc) {
      reftime + ((tsc - reftsc) / GHz)
    }
    mapply(unixtime, tl$tsc)
  }
}

# Calculate cycles since log entry of >= level ("lag") for each entry.
calculate_cycles <- function(tl) {
  # reference timestamp accumulator for update inside closure.
  # index is log level and value is reference timestamp for delta.
  ref <- as.numeric(rep(NA, 9))
  tscdelta <- function(level, time) {
    if (is.na(level)) { stop("level na") }
    if (is.na(time)) { stop("time na") }
    delta <- time - ref[level]
    ref[1:level] <<- time
    delta
  }
  mapply(tscdelta, tl$level, tl$tsc)
}

