printing
print: anInteger on: aStream
	| printName |
	printName := enumerators detect: [ :a | a value = anInteger ] ifFound: [ :a | a key ] ifNone: ['?'].
	aStream nextPutAll: printName, ' (', anInteger asString, ')'.