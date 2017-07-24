# timeliner nix library API:
#
#   timeliner.summary <shm-tarball>:
#     Generate summary data from a timeline for further processing.
#
#   timeliner.visualize <summary>:
#     Generate visualizations (PNG files) from timeline summary data.
#
# The output of timeliner.summary is the input to timeliner.visualize.
# The processing is split into two parts so that the summary data can
# be archived separately from the timeline files (e.g. to save space
# by keeping only the summary data and discarding the full timeline.)

{ pkgs ? import ../../nix/pkgs.nix {} }:

with pkgs; with stdenv;

let buildInputs = with rPackages; [ R dplyr readr ggplot2 bit64 mgcv ]; in

{
  # shmTarball: path to a tarball containing a Snabb shm folder.
  summary = shmTarball: runCommand "timeline-summary" { inherit buildInputs; } ''
      mkdir $out
      tar xf ${shmTarball}
      Rscript - <<EOF
        source("${./timeliner.R}")
        summarize_timeline("engine/timeline", "$out")
      EOF
    '';
  # summaryData: Output from the summary derivation above.
  visualize = summaryData: runCommand "timeline-visualization" { inherit buildInputs; } ''
    mkdir $out
    Rscript - <<EOF
      source("${./timeliner.R}")
      plot_timeline_summary("${summaryData}", "$out")
    '';
}

