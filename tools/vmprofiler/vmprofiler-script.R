#!/usr/bin/env nix-shell
#!nix-shell -i Rscript -p 'with pkgs; with rPackages; [ R purrr tibble dplyr ggplot2 bit64 ]'
suppressMessages(source("vmprofiler.R"))
args <- commandArgs(trailingOnly=T)
if (length(args) == 0) {
  stop("usage: vmprofiler <profile|where> file [file...]")
} else {
  cmd <- args[[1]]
  f <- NA
  if      (cmd == 'profile') { f <<- analyze_profile }
  else if (cmd == 'where')   { f <<- analyze_where }
  else                       { stop("bad command", cmd) }
  data <- read_files(args[2:length(args)])
  f(data)
}
