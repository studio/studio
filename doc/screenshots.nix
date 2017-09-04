{ pkgs ? (import ../.) }:
with pkgs; with builtins;
# RaptorJIT example program to be inspected.
let
   rj-example-1 = raptorjit.run ''
    -- Empty loop
    for i = 1, 100 do 
    end
    -- Small loop
    for i = 1, 100 do
      x = math.random() 
    end
    -- Branchy loop
    for i = 1, 100 do 
      if math.random() > 0.5 then x = 1 else x = 2 end
    end
  '';
  rj-example-2 = raptorjit.runDirectory
    (fetchFromGitHub { owner = "lukego";
                       repo = "rj-vmprof-bench";
                       rev = "a70c2a46cf03aac86f60833efe3b742453951702";
                       sha256 = "1l51wn1nlzxiz5xwjsv0ph8p8d31d5yy0ah04q3cy6ixgrlhlyyz";
                      });
  object1 = ''
    RJITProcess new fromPath: '${rj-example-1.product}' asFileReference
  '';
  object2 = ''
    RJITProcess new fromPath: '${rj-example-2.product}' asFileReference
  '';
 in

{
  RaptorJIT-Process-TraceOverview = studio-inspector-screenshot {
    name = "RaptorJIT-Process-TraceOverview";
    object = object1;
    view = "Traces Overview";
  };
  RaptorJIT-Process-TraceList = studio-inspector-screenshot {
    name = "RaptorJIT-Process-TraceList";
    object = object2;
    view = "Trace List";
  };
  RaptorJIT-Process-VMProfiles = studio-inspector-screenshot {
    name = "RaptorJIT-Process-VMProfiles";
    object = object2;
    view = "VMProfiles";
  };
  RaptorJIT-VMProfile-HotTraces = studio-inspector-screenshot {
    name = "RaptorJIT-VMProfile-HotTraces";
    object = ''
      ( ${object2} ) vmprofiles fourth
    '';
    view = "Hot Traces";
  };
  RaptorJIT-Trace-IRTree = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-IRTree";
    object = ''
      ( ${object2} ) auditLog traces last
    '';
    view = "IR Tree";
  };
  RaptorJIT-Trace-DWARF = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-DWARF";
    object = ''
      (( ${object2} ) auditLog traces last instVarNamed: #gctrace)
        instVarNamed: #dwarfValue
    '';
    view = "DWARF";
  };
}
