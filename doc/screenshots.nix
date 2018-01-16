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
                       rev = "ba7992aefc2a0bb1c9c45a69e2f18547fe5103ec";
                       sha256 = "01hw00bv4qgjhm8zm8ybk7m0y5q7mw2851bnm4l4vsy1in250qzs";
                      });
  object1 = ''
    RJITProcess new fromPath: '${rj-example-1.product}' asFileReference
  '';
  object2 = ''
    RJITProcess new fromPath: '${rj-example-2.product}' asFileReference
  '';
  # A root trace from the 'series' benchmark. This should be medium-size and interesting.
  trace1 = ''
    ( ${object2} ) auditLog traces detect: [ :tr |
      tr isRootTrace and: [ tr startLine beginsWith: 'bench/series' ] ]
  '';
 in

{
  RaptorJIT-Process-Events = studio-inspector-screenshot {
    name = "RaptorJIT-Process-Events";
    object = object1;
    view = "Events";
  };
  RaptorJIT-Process-VMProfile = studio-inspector-screenshot {
    name = "RaptorJIT-Process-VMProfile";
    object = object2;
    view = "VM Profile";
  };

  RaptorJIT-Trace-IRTree = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-IRTree";
    object = trace1;
    view = "IR Tree";
  };

  RaptorJIT-Trace-IRListing = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-IRListing";
    object = trace1;
    view = "IR Listing";
  };

  RaptorJIT-Trace-Bytecodes = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-Bytecodes";
    object = trace1;
    view = "Bytecodes";
  };

  /*
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
  RaptorJIT-Trace-IRListing = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-IRListing";
    object = ''
    ( ${object2} ) auditLog traces last
    '';
    view = "IR Listing";
  };
  RaptorJIT-Trace-DWARF = studio-inspector-screenshot {
    name = "RaptorJIT-Trace-DWARF";
    object = ''
      (( ${object2} ) auditLog traces last instVarNamed: #gctrace)
        instVarNamed: #dwarfValue
    '';
    view = "DWARF";
  };

  */
}
