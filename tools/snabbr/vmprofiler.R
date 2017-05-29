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

vmprofile.summarize <- function(inputdir, outputdir) {
  dir.create(outputdir, recursive=T, showWarnings=F)
  data <- vmprofile.read_files(Sys.glob(file.path(inputdir, "*")))
  vmprofile.save_data(outputdir, "overview", vmprofile.analyze_profile(data))
  vmprofile.save_data(outputdir, "what",     vmprofile.analyze_what(data))
  vmprofile.save_data(outputdir, "gc",       vmprofile.analyze_gc(data))
  vmprofile.save_data(outputdir, "where",    vmprofile.analyze_where(data))
}

# ------------------------------------------------------------
# Reading and decoding profiler samples
# ------------------------------------------------------------

vmprofile.states <- c("interp", "c", "gc", "exit", "record", "opt", "asm")
vmprofile.traces <- unlist(map(0:4096,
                     function(t) { paste(c("head","loop","foreign", "gc"),t,sep=".") }))
vmprofile.columns = c(vmprofile.states, vmprofile.traces)

vmprofile.read_files <- function(filenames) {
  return(do.call(rbind,lapply(filenames, vmprofile.read_file)))
}

vmprofile.read_file <- function(filename) {
  f <- file(filename, 'rb')
  profile <- tools::file_path_sans_ext(basename(filename))
  # XXX check magic and version
  seek(f, 8)
  tmp <- readBin(f, "double", n=length(vmprofile.states)+4097*4, size=8, endian="little")
  class(tmp) <- "integer64"    # cast to true type: int64
  samples <- as.numeric(tmp)   # convert to numeric for R
  close(f)
  tibble(profile = profile, where = vmprofile.columns, samples = samples) %>% dplyr::filter(samples>0)
}

# ------------------------------------------------------------
# Analysis to create summaries (data frames)
# ------------------------------------------------------------

vmprofile.analyze_profile <- function(data) {
  data %>%
    group_by(profile) %>%
    summarize(samples = sum(samples)) %>%
    ungroup() %>%
    transmute(profile = profile, percent = round(100*samples/sum(samples))) %>%
    arrange(-percent) %>%
    as.data.frame()
}

vmprofile.analyze_what <- function(data) {
  data %>%
    transform(what = str_match(where, "^[^.]*")) %>%
    group_by(what) %>%
    summarize(samples = sum(samples)) %>%
    ungroup() %>%
    transmute(what = what, percent = round(100*samples/sum(samples),1)) %>%
    arrange(-percent) %>%
    as.data.frame()
}

vmprofile.analyze_gc <- function(data) {
  data %>% filter(grepl("gc", where)) %>% vmprofile.analyze_where()
}

vmprofile.analyze_where <- function(data) {
  data %>%
    transform(percent = round(100*samples/sum(samples),1)) %>%
    arrange(profile, -percent) %>%
    select(profile, where, percent, samples) %>%
    filter(percent >= 0.5) %>%
    as.data.frame()
}

# ------------------------------------------------------------
# Utilities
# ------------------------------------------------------------

# Save a data frame to a directory in both .csv and .txt format.
vmprofile.save_data <- function(dir, name, data) {
  write_csv(data, file.path(dir, paste(name, '.csv', sep="")))
  capture.output(print(data, row.names=F), type="output",
                 file = file.path(dir, paste(name, '.txt', sep="")))
}

