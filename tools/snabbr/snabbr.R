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

