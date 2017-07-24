# latencyr.R: Process Snabb shared memory latency histogram objects

# ------------------------------------------------------------
# High-level API functions
# ------------------------------------------------------------

summarize_latency <- function(filename) {
  read_latency_histogram(filename) %>%
    mutate(csum = cumsum(bucket)) %>%
    group_by(usec = floor(log10(bound*1e6))) %>%
    summarize(percent = last(csum) / last(total))
}

read_latency_histogram <- function(filename) {
  f <- file(filename, "rb")
  minimum <- readBin(f, "double", n=1, size=8, endian="little")[[1]]
  log_growth_factor <- readBin(f, "double", n=1, size=8, endian="little")[[1]]
  bucketsU64 <- readBin(f, "double", n=510, size=8, endian="little")
  class(bucketsU64) <- "integer64"
  buckets <- as.numeric(bucketsU64)
  close(f)
  tibble(minimum = minimum,
       log_growth_factor = log_growth_factor,
       microseconds = c(0, minimum + (exp(log_growth_factor) ^ (1:507)), Inf),
       total = buckets[[1]],
       count = buckets[2:length(buckets)])
}

