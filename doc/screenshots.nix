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
  rj-example-2 = raptorjit.runTarball https://github.com/lukego/rj-vmprof-bench/archive/master.tar.gz;
  object = ''
    RJITProcess new fromPath: '${rj-example-1.product}' asFileReference
  '';
 in

{
  RaptorJIT-Process-TraceOverview = studio-inspector-screenshot {
    name = "RaptorJIT-Process-TraceOverview";
    object = object;
  };
  RaptorJIT-VMProfile-HotTraces = studio-inspector-screenshot {
    name = "RaptorJIT-VMProfile-HotTraces";
    object = ''
      ( ${object} ) vmprofiles fourth
    '';
  };
}
