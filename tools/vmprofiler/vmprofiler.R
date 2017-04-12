# vmprofiler.R: Process LuaJIT/Snabb VMProfile logs

options(warn=-1)

library(dplyr)
library(bit64)
library(tibble)
library(tools)
library(purrr)
library(readr)
library(stringr)

# ------------------------------------------------------------
# High-level API functions
# ------------------------------------------------------------

summarize_vmprofile <- function(inputdir, outputdir) {
  dir.create(outputdir, recursive=T, showWarnings=F)
  data <- read_files(Sys.glob(file.path(inputdir, "*")))
  save_data(outputdir, "overview", analyze_profile(data))
  save_data(outputdir, "what",     analyze_what(data))
  save_data(outputdir, "gc",       analyze_gc(data))
  save_data(outputdir, "where",    analyze_where(data))
}

# ------------------------------------------------------------
# Reading and decoding profiler samples
# ------------------------------------------------------------

states <- c("interp", "c", "gc", "exit", "record", "opt", "asm")
traces <- unlist(map(0:4096,
                     function(t) { paste(c("head","loop","foreign", "gc"),t,sep=".") }))
columns = c(states, traces)

read_files <- function(filenames) {
  return(do.call(rbind,lapply(filenames, read_file)))
}

read_file <- function(filename) {
  f <- file(filename, 'rb')
  profile <- tools::file_path_sans_ext(basename(filename))
  # XXX check magic and version
  seek(f, 8)
  tmp <- readBin(f, "double", n=length(states)+4097*4, size=8, endian="little")
  class(tmp) <- "integer64"    # cast to true type: int64
  samples <- as.numeric(tmp)   # convert to numeric for R
  tibble(profile = profile, where = columns, num = samples) %>% filter(num>0)
}

# ------------------------------------------------------------
# Analysis to create summaries (data frames)
# ------------------------------------------------------------

analyze_profile <- function(data) {
  data %>%
    group_by(profile) %>%
    summarize(num = sum(num)) %>%
    ungroup() %>%
    transmute(profile = profile, percent = round(100*num/sum(num),1)) %>%
    arrange(-percent) %>%
    as.data.frame()
}

analyze_what <- function(data) {
  data %>%
    transform(what = str_match(where, "^[^.]*")) %>%
    group_by(what) %>%
    summarize(num = sum(num)) %>%
    ungroup() %>%
    transmute(what = what, percent = round(100*num/sum(num),1)) %>%
    arrange(-percent) %>%
    as.data.frame()
}

analyze_gc <- function(data) {
  data %>% filter(grepl("gc", where)) %>% analyze_where()
}

analyze_where <- function(data) {
  data %>%
    transform(percent = round(100*num/sum(num),1)) %>%
    arrange(profile, -percent) %>%
    select(profile, where, percent) %>%
    filter(percent >= 0.5) %>%
    as.data.frame()
}

# ------------------------------------------------------------
# Utilities
# ------------------------------------------------------------

# Save a data frame to a directory in both .csv and .txt format.
save_data <- function(dir, name, data) {
  write_csv(data, file.path(dir, paste(name, '.csv', sep="")))
  capture.output(print(data, row.names=F), type="output",
                 file = file.path(dir, paste(name, '.txt', sep="")))
}

