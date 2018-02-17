accessing
enumerationTypeWith: aName
  ^alltypes detect: [ :t | t isEnumeration and: [ t includesName: aName ] ].
