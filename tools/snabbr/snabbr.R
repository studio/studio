# snabbr.R: Analyze Snabb process state (timeline, latency histogram, etc)

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
    facet_wrap(~ profile)
}

# ------------------------------------------------------------
# Timeline
# ------------------------------------------------------------

breath_efficiency <- function(br, cutoff=5000) {
  nonzero <- filter(br, packets>0)
  d <- nonzero %>% filter(cycles/packets <= cutoff)
  pct <- (nrow(nonzero) - nrow(d)) / nrow(nonzero)
  ggplot(d, aes(y = cycles / packets, x = packets)) +
    geom_point(color="blue", alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    labs(title = "Engine breath efficiency",
         subtitle = paste("Processing cost in cycles per packet ",
                          "(ommitting ", scales::percent(pct), " outliers above ", scales::comma(cutoff), " cycles/packet cutoff)",
                          sep=""),
         y = "cycles/packet",
         x = "packets processed in engine breath (burst size)") +
    expand_limits(x=1, y=1)
}

callback_efficiency <- function(cb) {
  d <- cb %>%
    transform(class = str_match(event, "class=[^ ]*")) %>%
    transform(packets = pmax(inpackets, outpackets)) %>%
    filter(packets>0)
  ggplot(d, aes(y = pmin(1000, cycles/packets), x = packets, color = group)) +
    geom_point(alpha=0.25, shape=1) +
    geom_smooth(se=F, weight=1, alpha=0.1) +
    facet_wrap(~ class) +
    theme(aspect.ratio = 1) +
    expand_limits(x = 0)
}
