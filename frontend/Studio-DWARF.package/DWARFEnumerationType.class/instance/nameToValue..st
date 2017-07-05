printing
nameToValue: enumName
	^enumerators detect: [ :a | a key = enumName ] ifFound: #value ifNone: [nil].
