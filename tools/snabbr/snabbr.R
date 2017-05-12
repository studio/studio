# snabbr.R: Analyze Snabb process state (timeline, latency histogram, etc)

library(plyr)
library(dplyr)
library(tidyr)
library(yaml)
library(ggplot2)

# ------------------------------------------------------------
# Read data
# ------------------------------------------------------------

read_process_set <- function (dir) {
  groupNames <- Sys.glob(file.path(dir, "groups", "*"))
  groups <- flatten(map(groupNames, read_group))
  # XXX obviously could be factored tighter...
  list(latency.histogram = ldply(groups[names(groups) == "latency.histogram"]),
       vmprofile = ldply(groups[names(groups) == "vmprofile"]),
       callbacks = ldply(groups[names(groups) == "callbacks"]),
       breaths = ldply(groups[names(groups) == "breaths"]))
}

read_group <- function (dir) {
  product_info <- yaml.load_file(file.path(dir, 'product-info.yaml'))
  group <- product_info$group
  processes <- Sys.glob(file.path(dir, "processes", "*"))
  data <- flatten(map(processes, read_process))
  lapply(data, function(x) { x$group <- group; x })
}

read_process <- function (dir) {
  process <- str_match(dir, "/([:alnum:]{3})[:alnum:]*-studio-product-snabb-process$")[2]
  data <- list(latency.histogram = read_latency_histogram(file.path(dir, "summary", "engine", "latency.histogram")),
               vmprofile = read_files(Sys.glob(file.path(dir, "summary", "engine", "vmprofile", "*"))),
               callbacks = read_rds(file.path(dir, "summary", "timeline", "callbacks.rds.xz")),
               breaths = read_rds(file.path(dir, "summary", "timeline", "breaths.rds.xz")))
  lapply(data, function(x) { x$process <- process; x })
}

# ------------------------------------------------------------
# Latency histogram
# ------------------------------------------------------------

summarize_latency_histogram <- function(data) {
  data %>%
    group_by(group, bucket = ceiling(log10(microseconds*1e6))) %>%
    summarize(count = sum(count))
}

plot_latency_histogram <- function (data) {
  ggplot(filter(data, count>0), aes(x=microseconds, y=count, color=group)) +
    geom_point(shape=1, alpha=0.75) +
    scale_y_log10(labels = scales::comma, breaks = 10 ^ (1:9)) +
    scale_x_log10(limits = c(1, 1e6), breaks = 10 ^ (1:6), labels = scales::comma) +
    annotation_logticks(sides="bl")
}

# ------------------------------------------------------------
# VMProfile
# ------------------------------------------------------------

plot_vmprofile <- function (data) {
  d <- data %>%
    group_by(group, process, profile, what = str_match(where, "^[^.]*")) %>%
    dplyr::summarize(num = sum(num)) %>%
    ungroup() %>%
    group_by(process, profile) %>%
    dplyr::mutate(percent = 100*num/sum(num))
  ggplot(d, aes(x = what, y = percent, color = group)) +
    geom_boxplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 0.9)) +
    facet_wrap(~ profile)
}

# ------------------------------------------------------------
# Timeline
# ------------------------------------------------------------

# Plot the efficiency (cycles per kilobit) of the engine at different mean packet sizes.
breath_efficiency <- function(br, minpackets=16, cutoff=1000) {
  big_enough_burst <- filter(br, packets >= minpackets)
  excluded_outliers <- filter(big_enough_burst, cycles/ ethbits * 1000 <= cutoff)
  d <- excluded_outliers
  percent_outliers <- (nrow(big_enough_burst) - nrow(excluded_outliers)) / nrow(big_enough_burst)
  ggplot(d, aes(y = 1000 * cycles / ethbits,
                x = bytes/packets,
                fill = group)) +
    # Bin into hexagons to show the frequency of performance/packetsize combos.
    # Hard-coded function of density to pick hopefully pleasing opacity.
    stat_binhex(aes(alpha = ..density..),
                      bins = 64, show.legend=F) +
    # Fit a curve to the data. Hard-coded shape (exponential with negative exponent.)
    geom_smooth(aes(color = group),
                method = 'lm',
                formula = y ~ exp(-x),
                se=F) +
    # X-axis has a logarithmic scale with appropriate break points.
    scale_x_log10(limits = c(64, 10000),
                  breaks = c(64, 128, 256, 512, 1024, 2048, 4096, 8192),
                  minor_breaks = c(96, 192, 384, 768, 1590, 3128, 6192)) +
    scale_y_continuous(limits = c(10, cutoff+1), breaks = seq(0, 1000, by=100), labels = scales::comma) +
    labs(title = "Engine breath efficiency",
       subtitle = paste("Processing cost by packet size.\n",
                        "Restricted to breaths with >= ", minpackets, " packets. Clamped ", scales::percent(percent_outliers), " outliers at ", scales::comma(cutoff), " cycles/packet ceiling.",
                        sep=""),
       y = "cpu cycles per kilobit of traffic",
       x = "mean bytes per packet in breath (log scale)")
}

breath_efficiency_table <- function(br) {
  d <- br %>%
    filter(packets>16) %>%
    group_by(group,
             burst = cut(packets, c(0, 1, 16, 32, 64, Inf)),
             bytes_per_packet = cut(bytes/packets, c(0, 60, 120, 250, 500, 1000, 1600, 4000, 10000), dig.lab=5)) %>%
    summarize(#cycles_per_packet = mean(cycles/packets),
              cycles_per_kbit = round(1000*mean(cycles/ethbits))) %>%
    na.omit() %>%
    ungroup() %>%
    spread(group, cycles_per_kbit)
  d
}

callback_efficiency_table <- function(cb) {
  d <- cb %>%
    transform(class = str_match(str_match(event, "class=[^ ]*"), "[^=]*$")) %>%
    transform(packets = pmax(inpackets, outpackets)) %>%
    transform(bits = 8 * pmax(inbytes, outbytes)) %>%
    group_by(bpp = cut(bytes/packets, c(0, 60, 100, 500, 1600, 10000), dig.lab=5),
             class, group) %>%
    filter(packets >= 32) %>%
    filter(n() > 5) %>%
    summarize(cycles_per_packet = mean(cycles/packets),
              cycles_per_bit = mean(cycles / bits))
  d <- d[!is.na(d$bpp),]
  list(cycles_per_packet = spread(select(d, -cycles_per_bit), group, cycles_per_packet),
       cycles_per_bit    = spread(select(d, -cycles_per_packet), group, cycles_per_bit))
}

callback_efficiency <- function(cb, cutoff=500) {
  d <- cb %>%
    transform(class = str_match(event, "class=[^ ]*")) %>%
    transform(packets = pmax(inpackets, outpackets),
              bytes = pmax(inbytes, outbytes)) %>%
    filter(packets>0)
  ggplot(d, aes(y = 1000 * cycles / (bytes * 8),
                x = bytes / packets,
                fill = group)) +
    stat_binhex(aes(alpha = ..density..),
                bins = 32, show.legend=F) +
    geom_smooth(aes(color = group),
                method = 'lm',
                formula = y ~ exp(-x),
                se=F) +
    scale_x_log10(limits = c(64, 10000),
                  breaks = c(64, 128, 256, 512, 1024, 2048, 4096, 8192),
                  minor_breaks = c(96, 192, 384, 768, 1590, 3128, 6192)) +
    scale_y_continuous(limits = c(10, cutoff+1), breaks = seq(0, 1000, by=100), labels = scales::comma) +
    facet_wrap(~ class) +
    theme(aspect.ratio = 1) +
    labs(title = "Engine breath efficiency",
         y = "cpu cycles per kilobit of traffic",
         x = "mean bytes per packet in breath (log scale)")
}

callback_bit_efficiency <- function(cb) {
  d <- cb %>%
    transform(class = str_match(event, "class=[^ ]*")) %>%
    transform(packets = pmax(inpackets, outpackets)) %>%
    transform(bits = 8 * pmax(inbytes, outbytes)) %>%
    transform(bytes_per_packet = bits/8/packets) %>%
    filter(packets>0)
  ggplot(d, aes(y = cycles/bits, x = bytes_per_packet, color = group)) +
    geom_point(alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    facet_wrap(~ class) +
    theme(aspect.ratio = 1) +
    scale_x_log10(limits = c(1, 10000)) +
    scale_y_log10(labels = scales::comma) +
    expand_limits(y = 0.01)
}

breath_size <- function(br) {
  active <- br %>%
    filter(lag(total_packets, 3) != total_packets)
  ggplot(active, aes(x = packets)) +
    stat_ecdf(aes(color = group)) +
    theme(aspect.ratio = 1) +
    scale_y_continuous(labels = scales::percent) +
    labs(title = "Number of packets per breath",
         subtitle = "Excludes idle periods.",
         y = "percentage",
         x = "packets processed in breath")
}

