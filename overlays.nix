[
  (self: super: {
    pharo = super.callPackage ./backend/pharo/vm {};
  })
  (self: super:
    with super.callPackage ./backend/frontend {};
    {
      studio = {
        inherit studio-gui studio-gui-vnc studio-base-image studio-image;
        raptorjit = super.callPackage ./backend/raptorjit {};
        snabbr = super.callPackage ./backend/snabbr {};
        timeliner = super.callPackage ./backend/timeliner {};
        vmprofiler = super.callPackage ./backend/vmprofiler {};
        dwarfish = super.callPackage ./backend/dwarfish {};
      };
    })
]

