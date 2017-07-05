printing
valueToName: aValue
   ^enumerators detect: [ :a | a value = aValue ] ifFound: #key ifNone: [nil].
