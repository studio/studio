library(dplyr)
library(bit64)
library(tibble)
library(tools)
library(purrr)

states <- c("interp", "c", "gc", "exit", "record", "opt", "asm")
traces <- unlist(map(0:4095,
                     function(t) { c(paste("head",t,sep="."), paste("loop",t,sep="."), paste("foreign",t,sep=".")) }))
columns = c(states, traces)

read_files <- function(filenames) {
  return(do.call(rbind,lapply(filenames, read_file)))
}

read_file <- function(filename) {
  f <- file(filename, 'rb')
  profile <- tools::file_path_sans_ext(basename(filename))
  # XXX check magic and version
  seek(f, 8)
  tmp <- readBin(f, "double", n=length(states)+4096*3, size=8, endian="little")
  class(tmp) <- "integer64"    # cast to true type: int64
  samples <- as.numeric(tmp)   # convert to numeric for R
  tibble(profile = profile, where = columns, num = samples) %>% filter(num>0)
}

analyze_profile <- function(data) {
  data %>%
    group_by(profile) %>%
    summarize(num = sum(num)) %>%
    ungroup() %>%
    transmute(profile = profile, percent = round(100*num/sum(num),1)) %>%
    arrange(-percent) %>%
    as.data.frame() %>% print(row.names=F)
}

analyze_where <- function(data) {
  data %>%
    transform(percent = round(100*num/sum(num),1)) %>%
    arrange(profile, -percent) %>%
    select(profile, where, percent) %>%
    filter(percent >= 1) %>%
    as.data.frame() %>% print(row.names=F)
}
