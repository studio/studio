#!/usr/bin/env Rscript
suppressMessages(source("timeliner.R"))
args <- commandArgs(trailingOnly=T)
if (length(args) == 0) {
  stop("no timeline log(s) provided")
} else {
  ggplot_timelines(args)
  ggsave("timeline-cycles_per_packet-by_process-per_app.png")
}
