[
  (self: super: {
    pharo = super.callPackage ./pharo/vm {};
  })
  (self: super: {
    studio-vnc = super.callPackage ./studio/frontend {};
  })
]
