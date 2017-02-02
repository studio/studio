# Create R visualizations of Snabb timeline logs

with import <nixpkgs> {};
with stdenv; with lib;

let
  snabb = (import ../snabb).timeline-pmu;

  # Create CSV file from timeline
  mkTimelineCSV = shm:
    mkDerivation {
      name = "timeline-csv";
      src = shm;
      __noChroot = true;
      buildInputs = [ snabb which ];
      #prePatch = "set -x";
      #postPatch = "ls -l";
      buildPhase = ''
         /var/setuid-wrappers/sudo bash ${./timeline2csv.sh} . timeline.csv
      '';
      installPhase = ''
        mkdir -p $out
        cp timeline.csv $out/
      '';
    };

  # Create R summary of CSV
  mkTimeliner = csv:
    mkDerivation {
      name = "timeliner";
      buildInputs = with rPackages; [ R ggplot2 dplyr ];
      builder = writeText "timeliner-builder.sh" ''
        source $stdenv/setup
        mkdir $out
        Rscript ${./timeliner.R} ${csv}
        cp foo.txt $out/
      '';
    };

in
rec {
  timeline = mkTimelineCSV /home/luke/shm/var/run/snabb/29771;
  timeliner = mkTimeliner timeline;
}


