accessing
enumerationTypeWith: aName
  ^types detect: [ :t | t isEnumeration and: [ t includesName: aName ] ].
