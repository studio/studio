{ pkgs ? (import ./pkgs.nix) {} }:

with pkgs;
let snabbr = import ../tools/snabbr {}; in

{
  snabbProcessTarball = dir:
    runCommand "snabb-process-tarball" { inherit dir; }
      ''
        cp -pr $dir dir
        (cd dir && tar cf ../state.tar *)
        # xz -0 is fast & effective on snabb state
        xz -0 -T0 state.tar
        mv state.tar.xz $out
      '';

  # Snabb process state snapshot. Source is a compressed tarball.
  snabbProcess = tarball:
    let timelineSummary = snabbr.summary tarball; in
    runCommand "studio-product-snabb-process"
      { inherit tarball timelineSummary; }
      ''
        mkdir $out
        echo 'type: snabbProcess' > $out/product-info.yaml
        ln -s $tarball $out/state.tar.xz
        mkdir $out/summary
        # Create summary data from the timeline
        ln -s $timelineSummary $out/summary/timeline
        # Extract small relevant files
        (cd $out/summary; tar -xf $tarball engine/latency.histogram engine/vmprofile)
      '';

  # Snabb process group. Source is a list of process state snapshots.
  snabbProcessGroup = groupName: processes:
    runCommand "studio-product-snabb-process-group" { inherit groupName processes; }
      ''
        mkdir -p $out/processes
        echo "type: snabbProcessGroup" >  $out/product-info.yaml
        echo "group: $groupName"     >> $out/product-info.yaml
        for p in $processes; do
          ln -s $p $out/processes/
        done
      '';

  # Set of Snabb process groups.
  snabbProcessSet = groups:
    runCommand "studio-product-snabb-process-set" { inherit groups; }
      ''
        mkdir -p $out/groups
        echo 'type: snabbProcessGroups' > $out/product-info.yaml
        for g in $groups; do
          ln -s $g $out/groups/
        done
      '';

  snabbProcessReport = processSet:
    snabbr.report processSet;
}

