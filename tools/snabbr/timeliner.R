# timerliner.R: Process Snabb timeline logs

library(dplyr)
library(stringr)
library(bit64)
library(readr)
library(ggplot2)

# ------------------------------------------------------------
# High-level API functions
# ------------------------------------------------------------

# Load a binary timeline and save summary data for further processing.
summarize_timeline <- function(filename, outdir) {
  save_timeline_summaries(read_timeline(filename), outdir)
}

# Load summary data and save diverse visualizations.
plot_timeline_summary <- function(summarydir, outdir) {
  dir.create(outdir, recursive=T, showWarnings=F)
  # Breaths
  br <- read_rds(file.path(summarydir, "breaths.rds.xz"))
  ggsave(file.path(outdir, "breath_duration.png"),   breath_duration(br))
  ggsave(file.path(outdir, "breath_outliers.png"),   breath_outliers(br))
  ggsave(file.path(outdir, "breath_efficiency.png"), breath_efficiency(br))
  # Callbacks
  cb <- read_rds(file.path(summarydir, "callbacks.rds.xz"))
  ggsave(file.path(outdir, "callback_efficiency.png"), callback_efficiency(cb))
}

# ------------------------------------------------------------
# Reading and decoding timelines
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# Saving CSV summaries of timelines
# ------------------------------------------------------------

# Save R object summaries of a timeline.
save_timeline_summaries <- function(tl, outdir=".") {
  if (!dir.exists(outdir)) { dir.create(outdir, recursive=T) }
  br <- breaths(tl)
  cb <- callbacks(tl)
  save_data(br, file.path(outdir, "breaths.rds.xz"))
  save_data(cb, file.path(outdir, "callbacks.rds.xz"))
}

save_data <- function(data, filename) {
  message("Saving ", filename)
  write_rds(data, filename, compress="xz")
}

# Create a data frame with one row for each breath.
breaths <- function(tl) {
  tl %>% 
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(breath = arg0,
           total_packets = arg1, total_bytes = arg2, total_ethbits = arg3,
           packets = arg1-lag(arg1), bytes = arg2-lag(arg2), ethbits = arg3-lag(arg3)) %>%
    filter(grepl("breath_end", event)) %>%
    na.omit() %>%
    select(tsc, unixtime, cycles, numa, core,
           breath, total_packets, total_bytes, total_ethbits, packets, bytes, ethbits)
}

# Create a data frame with one row for each app callback.
callbacks <- function(tl) {
  tl %>% filter(grepl("^app.(pull|push)", event)) %>%
    mutate(inpackets = arg0 - lag(arg0), inbytes = arg1 - lag(arg1),
           outpackets = arg2 - lag(arg2), outbytes = arg3 - lag(arg3)) %>%
    mutate(packets = pmax(inpackets, outpackets), bytes = pmax(inbytes + outbytes)) %>%
    filter(grepl("^app.(pushed|pulled)", event)) %>%
    na.omit() %>%
    select(tsc, unixtime, cycles, numa, core,
           event, packets, bytes, inpackets, inbytes, outpackets, outbytes)
}

# ------------------------------------------------------------
# Visualizing the callbacks summary
# ------------------------------------------------------------

breath_outliers <- function(br, cutoff=1000000) {
  d <- filter(br, cycles>cutoff)
  ggplot(d, aes(y = cycles, x = packets)) +
    scale_y_continuous(labels = scales::comma) +
    geom_point(alpha=0.5, color="blue") +
    labs(title = "Outlier breaths",
           subtitle = paste("Breaths that took more than ", scales::comma(cutoff), " cycles ",
                            "(", scales::percent(nrow(d)/nrow(br)), " of sampled breaths)", sep=""),
           x = "packets processed in engine breath (burst size)")
}

breath_duration <- function(br, cutoff=1000000) {
  d <- filter(br, cycles <= cutoff)
  ggplot(d, aes(y = cycles, x = packets)) +
    geom_point(color="blue", alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    labs(title = "Breath duration",
         subtitle = "")
}

breath_efficiency <- function(br, cutoff=5000) {
  nonzero <- filter(br, packets>0)
  d <- nonzero %>% filter(cycles/packets <= cutoff)
  pct <- (nrow(nonzero) - nrow(d)) / nrow(nonzero)
  ggplot(d, aes(y = cycles / packets, x = packets)) +
    geom_point(color="blue", alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    labs(title = "Engine breath efficiency",
         subtitle = paste("Processing cost in cycles per packet ",
                          "(ommitting ", scales::percent(pct), " outliers above ", scales::comma(cutoff), " cycles/packet cutoff)",
                          sep=""),
         y = "cycles/packet",
         x = "packets processed in engine breath (burst size)")
}

callback_efficiency <- function(cb) {
  d <- cb %>%
        mutate(packets = pmax(inpackets, outpackets)) %>%
        filter(packets>0)
  ggplot(d, aes(y = pmin(1000, cycles/packets), x = packets)) +
    geom_point(color="blue", alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    facet_wrap(~ event)
}

