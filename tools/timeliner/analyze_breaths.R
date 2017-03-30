library(tidyr)
library(ggplot2)

# Summarize breaths that fall in the same time bin.
timebin_breaths <- function(b) {
  b %>%
    mutate(group = floor(seconds)) %>%
    group_by(group) %>%
    summarize(time = last(seconds) - first(seconds),
              `Mpps (freed)` = (last(total_packets) - first(total_packets)) / 1e6 / time,
              `Gbps (freed)` = (last(total_ethbits) - first(total_ethbits)) / 1e9 / time,
              `packets/breath` = mean(packets),
              `cycles/packet (<1000)` = pmin(1000, (last(tsc)-first(tsc)) / (last(total_packets) - first(total_packets))),
              `bytes/packet` = (last(total_bytes)-first(total_bytes)) / (last(total_packets) - first(total_packets)),
              `usec/breath (<1000)` = pmin(1000, (time * 1e6) / (last(breath) - first(breath))))
#    filter(time > 0.8)
}

plot_breaths <- function(b) {
  tb <- timebin_breaths(b) %>%
    gather(metric, value, `Mpps (freed)`, `Gbps (freed)`, `packets/breath`, `cycles/packet (<1000)`, `bytes/packet`, `usec/breath (<1000)`) %>%
    transform(metric = factor(metric, levels=c("Gbps (freed)", "Mpps (freed)", "cycles/packet (<1000)", "packets/breath", "bytes/packet", "usec/breath (<1000)")))
  ggplot(tb, aes(x=group, y=value, color=metric)) +
    geom_point(alpha=0.25) + geom_line() + 
    scale_x_continuous(breaks = seq(0, 1000, 4)) +
    facet_grid(metric~., scales="free_y") +
    labs(x = "time (seconds)")
}

prepare_breaths <- function(b) {
  b %>%
    mutate(`Mpps (freed)` = packets / cycles * Hz / 1e6,
           `Gbps (freed)` = ethbits / cycles * Hz / 1e9,
           `packets/breath` = packets,
           `cycles/packet (<1000)` = pmin(1000, cycles/packets),
           `bytes/packet` = bytes/packets,
           `usec/breath (<1000)` = cycles * GHz * 1000)
}

plot_breaths2 <- function(b) {
  bb <- prepare_breaths(b) %>%
    gather(metric, value, `Mpps (freed)`, `Gbps (freed)`, `packets/breath`, `cycles/packet (<1000)`, `bytes/packet`, `usec/breath (<1000)`) %>%
    mutate(unixtime = unixtime / 1e9,
           seconds = floor(unixtime), 
           metric = factor(metric, levels=c("Gbps (freed)", "Mpps (freed)", "cycles/packet (<1000)", "packets/breath", "bytes/packet", "usec/breath (<1000)")))
  bb$seconds <- as.factor(bb$seconds)
  hi <- function(y) { mean(y) + sd(y) }
  lo <- function(y) { mean(y) - sd(y) }
  ggplot(bb, aes(x=as.factor(seconds), y=value, color=metric)) +
#    geom_boxplot(aes(x=as.factor(5*floor(as.integer(seconds) / 5))), outlier.shape=1) +
    geom_smooth(aes(x=as.integer(seconds))) +
#    geom_point(alpha=0.02) +
#    geom_smooth(geom="line") +
#    stat_summary(geom = "ribbon", fun.data = mean_sdl) +
#    geom_smooth(se=F) +
#    stat_summary(fun.data = mean_sdl, geom="ribbon", na.rm=T) +
#    geom_point(alpha=0.25) + #geom_line() + 
#    scale_x_continuous(breaks = seq(0, 1000, 4)) +
    facet_grid(metric~., scales="free_y")
#    labs(x = "time (seconds)")
  
}

dat <- function(pid=1832) {
  preprocess_timeline(paste("/Users/lukegorrie/shm/vmprofile/test3dt/var/run/snabb3/",pid,"/engine/timeline",sep=""), as.character(pid))
  b <- read_rds(paste(pid, '/', 'breaths.rds.xz', sep=''))
  bb <- b %>% mutate(seconds = (unixtime - min(unixtime)) / 1e9)
  bb$Hz <- 2.333e9
  bb$GHz <- 2.333
  bb
}



prep <- function(b) {
  b %>%
    mutate(`Mpps (freed)` = packets / cycles * Hz / 1e6,
           `Gbps (freed)` = ethbits / cycles * Hz / 1e9,
           `packets/breath` = packets,
           `cycles/packet (<1000)` = pmin(1000, cycles/packets),
           `bytes/packet` = bytes/packets,
           `usec/breath (<1000)` = cycles * GHz * 1000) %>%
    gather(metric, value, `Mpps (freed)`, `Gbps (freed)`, `packets/breath`, `cycles/packet (<1000)`, `bytes/packet`, `usec/breath (<1000)`) %>%
    transform(metric = factor(metric, levels=c("Gbps (freed)", "Mpps (freed)", "cycles/packet (<1000)", "packets/breath", "bytes/packet", "usec/breath (<1000)")))
}

prep2 <- function(b) {
  prep(b) %>%
    group_by(time = floor(seconds), metric) %>%
    summarize(Q95 = quantile(value, 0.95, na.rm=T),
              Q75 = quantile(value, 0.75, na.rm=T),
              Q50 = quantile(value, 0.50, na.rm=T),
              Q25 = quantile(value, 0.25, na.rm=T),
              Q05 = quantile(value, 0.05, na.rm=T),
              mean = mean(value))
}

plot2 <- function(b) {
  prep2(bb) %>%
    ggplot(aes(y=mean, x=time, color=metric)) +
    geom_point(alpha=0.25) +
    geom_line(aes(y=Q50), linetype="dotted") +
#    geom_ribbon(aes(ymin=Q25, ymax=Q75, fill=metric), alpha=0.25, color=NA) +
#    geom_ribbon(aes(ymin=Q05, ymax=Q95, fill=metric), alpha=0.25, color=NA) +
    geom_line() +
    facet_grid(metric~., scales="free_y")
}
