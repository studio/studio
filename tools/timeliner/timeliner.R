library(dplyr)
library(stringr)
library(bit64)
library(ggplot2)

# Counter for automatically assigning process numbers when in doubt
count <- 0
counter <- function () { counter <<- count + 1; count }

# This special filename format is recognized:
#   .../[$group/]$process/engine/timeline
# ... and in this case the group and process names are used for the data.
# if group is not matched then it is left blank, if process is not matched then one is assigned.
read_timeline <- function(filename) {
  message("  reading ", filename)
  group <- str_match(filename, "([^/]+)/[^/]+/engine/timeline")[2]
  process <- str_match(filename, "([^/]+)/engine/timeline")[2]
  if (is.na(process)) { process <- paste("p", counter(), sep="") }
  process <- paste(group, process)
  message("    group=", group, " process=", process)
  timeline <- read_binary_timeline(filename)
  timeline$cycles <- cycles(timeline)
  timeline$unixtime <- unix_time(timeline)
  timeline$group <- as.factor(group)
  timeline$process <- as.factor(process)
  timeline$numa <- as.factor(timeline$numa)
  return(timeline)
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
  message("    decoding entries")
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
  message("    decoding string table")
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
  
# Calculate cycles for each event.
cycles <- function(tl) {
  message("    calculating cycle deltas")  
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

unix_time <- function(tl) {
  message("    calculating unix timestamps")  
  # Estimate CPU frequency
  times <- filter(tl, grepl("got_monotonic_time", event))
  if (length(times) < 2) {
    message("      failed: need at least two unix timestamps")  
    NA
  } else {
    Hz <- (max(times$tsc)-min(times$tsc)) / (max(times$arg0)-min(times$arg0))
    message("      estimated CPU base frequency: ", round(Hz,3), " GHz")  
    reftsc <- last(times$tsc)
    reftime <- last(times$arg0)
    unixtime <- function(tsc) {
      reftime + ((tsc - reftsc) / Hz)
    }
    mapply(unixtime, tl$tsc)
  }
}

read_timelines <- function(filenames) {
  return(do.call(rbind,lapply(filenames, read_timeline)))
}

# Tables of information:
#  Groupings: overall, group, pid
# Common columns:
#  tsc, unixtime
# Specifics:
# breaths:
# callbacks:
# engine:

breaths <- function(data) {
  data %>% 
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(packets = arg1-lag(arg1), bytes = arg2-lag(arg2)) %>%
    filter(grepl("breath_end", event)) %>%
    na.omit() %>%
    select(tsc, unixtime, cycles, group, numa, core, process,
           packets, bytes)
}

callbacks <- function(data) {
  data %>% filter(grepl("^app.(pull|push)", event)) %>%
    mutate(inpackets = arg0 - lag(arg0), inbytes = arg1 - lag(arg1),
           outpackets = arg2 - lag(arg2), outbytes = arg3 - lag(arg3)) %>%
    mutate(packets = pmax(inpackets, outpackets), bytes = pmax(inbytes + outbytes)) %>%
    filter(grepl("^app.(pushed|pulled)", event)) %>%
    na.omit() %>%
    select(tsc, unixtime, cycles, group, numa, core, process,
           event, packets, bytes, inpackets, inbytes, outpackets, outbytes)
}

# Efficiency terrain (overall)

prepare_efficiency_terrain <- function(data) {
  data %>% filter(grepl("^engine.breath_end$", event)) %>%
    transmute(packets=arg1, bpp=arg2, bits=arg1*arg2*8, bpc = bits/cycles) %>%
    na.omit() %>%
    group_by(floor(packets/20), floor(bpp/64)) %>% summarize(bpp = floor(first(bpp)/64)*64, packets=floor(first(packets)/20)*20, bpc = mean(bpc))
}

ggplot_efficiency_terrain <- function(data) {
  message("  plotting")
  ggplot(data, aes(y=packets, x=bpp)) + #, fill=bpc, color=bpc, z=bpc)) +
  geom_raster(aes(fill=bpc), interpolate=T) +
    stat_contour(aes(z=bpc), color="white", alpha=0.075) +
    scale_color_gradient(low="red", high="blue") +
    labs(title = "Map of 'efficiency terrain' in bits of traffic per CPU cycle (bpc)",
         x = "bytes per packet (average for breath)",
         y = "packets processed in breath (burst size)")
}

# Efficiency terrain (per app)

prepare_app_terrain <- function(data) {
  data %>% filter(grepl("^app.(pull|push)", event)) %>%
    rowwise() %>% mutate(tpackets = max(arg0, arg2), tbytes = max(arg1, arg3)) %>% ungroup() %>%
    mutate(packets = tpackets - lag(tpackets), bytes = tbytes - lag(tbytes), bpp = bytes/packets, bpc = bytes*8/cycles) %>%
    filter(grepl("^app.(pushed|pulled)", event))
}

ggplot_app_terrain <- function(data) {
  data <- data %>%
    group_by(event, floor(packets/20), floor(bpp/20)) %>%
    summarize(bpp = floor(first(bpp)/64)*64, packets=floor(first(packets)/20)*20, bpc = min(100, mean(bpc))) %>%
    ungroup()
  ggplot(data, aes(y=packets, x=bpp)) +
    geom_raster(aes(fill=bpc), interpolate=T) +
    facet_wrap(ncol=2, ~event) 
}

# Per second

prepare_per_second <- function(data) {
  Hz <- GHz(data)*1000000000
  data %>%
    filter(grepl("breath_start", event)) %>%
    mutate(totalpackets = arg1, totalbytes = arg2, totalbits=arg3) %>%
    group_by(process) %>%
    group_by(process, sec = round((tsc - min(tsc))/Hz), 1) %>%
    summarize(time = (last(tsc) - first(tsc)) / Hz,
              packets = (last(totalpackets) - first(totalpackets)) / time,
              bytes = (last(totalbytes) - first(totalbytes)) / time,
              gigabits = (last(totalbits) - first(totalbits)) / time)
}

GHz <- function(data) {
  time <- data %>% filter(grepl("got_monotonic_time", event))
  (max(time$tsc)-min(time$tsc)) / (max(time$arg0)-min(time$arg0))
}

ggplot_per_second <- function(data) {
  ggplot(data, aes(y=packets/1e6, x=sec, color=process)) +
    geom_line() +
    labs(y="Mpps",
         x="seconds since process started",
         title="Traffic rate over time")
}

kpi <- function(data) {
  data %>% 
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(packets = arg1-lag(arg1), bytes = arg2-lag(arg2)) %>%
    filter(grepl("breath_end", event)) %>%
    na.omit() %>%
    group_by(burst_size = cut(packets, c(0, 16, 32, 64,999), include.lowest=T), numa, group) %>%
    summarize(cycles_per_byte   = median(cycles/bytes),
              cycles_per_packet = median(cycles/packets),
              cycles_per_breath = median(cycles),
              packets_per_breath = median(packets),
              count = n())
}

kpi2 <- function(data) {
  data %>%
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(packets = arg1-lag(arg1), bytes = arg2-lag(arg2)) %>%
    filter(grepl("breath_end", event)) %>%
    na.omit() %>%
    group_by(burst_size = cut(packets, c(-1, 0, 16, 32, 64,999)), group) %>%
    summarize()
}

kpi3 <- function(data) {
  data %>%
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(packets = arg1-lag(arg1), bytes = arg2-lag(arg2)) %>%
    filter(grepl("breath_end", event)) %>%
    na.omit() %>%
    mutate(cycles_per_byte   = cycles/bytes,
           cycles_per_packet = cycles/packets,
           cycles_per_breath = cycles,
           packets_per_breath = packets)
}

# KPIs per app

kpi_app <- function(data) {
  data %>% filter(grepl("^app.(pull|push)", event)) %>%
    rowwise() %>% mutate(tpackets = max(arg0, arg2), tbytes = max(arg1, arg3)) %>% ungroup() %>%
    mutate(packets = tpackets - lag(tpackets), bytes = tbytes - lag(tbytes),
           bpp = bytes/packets, cycles_per_packet = cycles/packets, cycles_per_byte = cycles/bytes) %>%
    filter(grepl("^app.(pushed|pulled)", event)) %>%
    na.omit() %>%
    group_by(group, event, burst_size = cut(packets, c(-1, 0, 16, 32, 64,999))) %>%
    summarize(median_packets_per_breath = median(packets),
              median_cycles_per_packet = round(median(cycles_per_packet), 1),
              median_cycles_per_byte = round(median(cycles_per_byte), 3),
              mean_bytes_per_packet = round(sum(bytes)/sum(packets), 0),
              n = n())
}

add_breath_statistics <- function(data) {
#  data %>%
    
}

# Graph: engine cycles per packet

prepare_cycles_per_packet <- function(data) {
  data %>% 
    filter(grepl("breath_end|breath_start", event)) %>%
    mutate(packets = arg1-lag(arg1), bytes = arg2-lag(arg2)) %>%
    filter(grepl("breath_end", event)) %>%
    filter(packets>0) %>%
    na.omit()
}

ggplot_cycles_per_packet <- function(data) {
  ggplot(data, aes(x=packets, y=cycles, fill=..density..*100)) +
    stat_binhex() +
    theme(aspect.ratio = 1) +
    facet_wrap(~group) +
    scale_fill_gradient(name="% of breaths", low="lightgray", high="blue") +
#    geom_point(alpha=0.1) +
#    geom_smooth() +
#    scale_y_log10(labels = scales::comma) +
#    scale_y_continuous(labels = scales::comma, limits = c(0, 200000), breaks=seq(0, 200000, 20000)) +
    scale_y_log10() +
    scale_x_continuous(labels = scales::comma, limits = c(0, 512), breaks=seq(0, 512, 64)) +
    labs(title = "Cycles per breath compared with packets per breath",
         x="packets processed in breath",
         y="cycles for breath",
         color="%")
}

# Graph: app cycles per packet

prepare_app_cycles_per_packet <- function(timeline) {
  message("  preparing data")
  timeline %>%
    filter(grepl("^app.(push|pull)", event)) %>%
    # Just the information needed for the graph
    mutate(what = gsub("^app.(pushed|pulled) app=P[0-9]+_(.*)$", "\\1 \\2", event),
           id = as.factor(paste(group, process)),
           packets = arg0-lag(arg0)+arg2-lag(arg2)) %>%
    # Just meaningful events
    filter(grepl("^app.(pushed|pulled)", event)) %>%
    filter(!is.na(cycles) & !is.na(packets) & packets>0)
}

ggplot_app_cycles_per_packet <- function(data) {
  message("  plotting")
  ggplot(data, aes(x=packets, y=cycles/packets, color=process)) +
    facet_wrap(~ what) +
    geom_point(alpha=0.25) +
#    geom_smooth(method=loess) +
#    scale_y_log10(limits = c(0, 1000000)) + # , breaks=seq(0, 1000000, 1)) +
    scale_y_log10() +
    scale_x_continuous(limits = c(0, 512), breaks=seq(0, 512, 64)) +
    labs(title = "Packet processing cost (cycles/packet) breakdown",
         x = "number of packets processed together in a batch",
         y = "cycles per packet")
}

save <- function(filename) {
  message("  saving ", filename)
  ggsave(filename)
}

analyze_timelines <- function(filenames) {
  message("Reading timeline files")
  tl <- read_timelines(filenames)
  message("Creating app-wise cycles-per-packet graphs")
  appcyc <- prepare_app_cycles_per_packet(tl)
  plot <- ggplot_app_cycles_per_packet(appcyc)
  save("timeline-cycles_per_packet-by_process-per_app.png")
}

