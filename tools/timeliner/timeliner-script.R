#!/usr/bin/env nix-shell
#!nix-shell -i Rscript -p 'with pkgs; with rPackages; [ R dplyr ggplot2 bit64 ]'
suppressMessages(source("timeliner.R"))
args <- commandArgs(trailingOnly=T)
if (length(args) == 0) {
  stop("no timeline log(s) provided")
} else {
  analyze_timelines(args)
}
