[
  (self: super: {
    pharo = super.callPackage ./pharo/vm {};
  })
  (self: super:
    with super.callPackage ./studio/frontend {};
    {
      inherit studio-gui studio-gui-vnc studio-base-image studio-image;
    })
]
