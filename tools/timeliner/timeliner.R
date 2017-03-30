library(tidyverse)
library(tools)
library(stringr)

# filename can be in one of two formats:
#   group-process.csv (e.g. master-219.csv)
#   process.csv       (e.g. 219.csv)
# The group and process names are included as columns.
read_timeline <- function(filename) {
  process <- file_path_sans_ext(basename(filename))
  # if there is a group name then extract that & remove it from the process
  group <- str_match(process, "^(.+)-")[2]
  process <- str_replace(process, "^(.+)-", "")
  timeline <- read_delim(filename, ";")
  timeline$group <- as.factor(group)
  timeline$process <- as.factor(process)
  timeline$numa <- as.factor(timeline$numa)
  return(timeline)
}

read_timelines <- function(filenames) {
  return(do.call(rbind,lapply(filenames, read_timeline)))
}

prepare_app_cycles_per_packet <- function(timeline) {
  timeline %>%
    # Just events that provide time reference for pull/push calls
    filter(grepl("initialized breath|pulled|pushed", message)) %>%
    # Just the information needed for the graph
    transmute(message = message, 
              event = gsub("^(push|pull).*\\(.*\\.([^.]*)\\).*", "\\1 \\2", message),
              id = as.factor(paste(group, process)),
              cycles = tsc - lag(tsc),
              packets = arg0+arg2) %>%
    # Just pull/push calls
    filter(grepl("^(pushed|pulled)", message)) %>%
    filter(!grepl("^(pulled input packets|pushed output packets)", message)) %>%
    # Just meaningful events
    filter(!is.na(cycles) & !is.na(packets) & packets>0)
}

ggplot_app_cycles_per_packet <- function(data) {
  ggplot(data, aes(x=packets, y=cycles/packets, color=id)) +
    facet_wrap(~ event) +
    geom_point(alpha=0.025) +
    geom_smooth(method=loess) +
    scale_y_continuous(limits = c(0, 1000), breaks=seq(0, 1000, 100)) +
    scale_x_continuous(limits = c(0, 512), breaks=seq(0, 512, 64)) +
    labs(title = "Packet processing cost (cycles/packet) breakdown",
         x = "number of packets processed together in a batch",
         y = "cycles per packet")
}

ggplot_timelines <- function(filenames) {
  ggplot_app_cycles_per_packet(prepare_app_cycles_per_packet(read_timelines(filenames)))
}

