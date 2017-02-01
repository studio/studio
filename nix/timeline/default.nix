# Create R visualizations of Snabb timeline logs

with import <nixpkgs> {};
with stdenv; with lib;

let
  snabb = (import ../snabb).timeline-pmu;
  timelineCSV = shm:
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
in
{
  timeline = timelineCSV /home/luke/shm/var/run/snabb/29771;
}


