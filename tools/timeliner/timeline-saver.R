# timeline-saver.R: Save extensive summary data from a timeline to files.
# Hopefully saves 90% of the useful information in 10% of the space...
# Data frame is saved using readr with compression enabled.

library(dplyr)
library(readr)

# Frontend for loading a binary timeline and saving R summaries.
preprocess_timeline <- function(filename, outdir) {
  save_timeline_summaries(read_timeline(filename), outdir)
}

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

