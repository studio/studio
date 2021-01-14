[
  (self: super: {
    pharo = super.callPackage ./backend/pharo/vm {};
  })
  (self: super:
    with super.callPackage ./backend/frontend {};
    {
      inherit studio studio-gui studio-gui-vnc studio-base-image studio-image studio-inspector-screenshot studio-decode studio-env;
      raptorjit = super.callPackage ./backend/raptorjit {};
      snabb = super.callPackage ./backend/snabb {};
      snabbr = super.callPackage ./backend/snabbr {};
      timeliner = super.callPackage ./backend/timeliner {};
      vmprofiler = super.callPackage ./backend/vmprofiler {};
      dwarfish = super.callPackage ./backend/dwarfish {};
      disasm = super.callPackage ./backend/disasm {};
      Moz2D = super.callPackage ./backend/Moz2D {};
    })
]

