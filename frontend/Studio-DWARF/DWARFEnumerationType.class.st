Class {
	#name : #DWARFEnumerationType,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'type',
		'enumerators'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFEnumerationType >> byteSize [
	^ type byteSize.
]

{ #category : #decoding }
DWARFEnumerationType >> decode: byteArray address: address flashback: flashback [
	^type decode: byteArray address: address flashback: flashback.
]

{ #category : #initialization }
DWARFEnumerationType >> from: dict via: references [
	name := dict at: 'name' ifAbsent: [nil].
	type := references at: (dict at: 'type').
	enumerators :=
		dict values
			select: #isDictionary
			thenCollect: [ :x | (x at: 'name') -> (x at: 'const_value') ].
	enumerators sort: [ :a :b | a value < b value ].
]

{ #category : #accessing }
DWARFEnumerationType >> icon [
   ^ Smalltalk ui iconNamed: #radioButtonOn.
]

{ #category : #printing }
DWARFEnumerationType >> includesName: aName [
   ^enumerators detect: [ :a | a key = aName ] ifFound: [true] ifNone: [false].

]

{ #category : #initialization }
DWARFEnumerationType >> isEnumeration [
	^true
]

{ #category : #printing }
DWARFEnumerationType >> nameToValue: enumName [
	^enumerators detect: [ :a | a key = enumName ] ifFound: #value ifNone: [nil].

]

{ #category : #printing }
DWARFEnumerationType >> print: anInteger on: aStream [
	| printName |
	printName := enumerators detect: [ :a | a value = anInteger ] ifFound: [ :a | a key ] ifNone: ['?'].
	aStream nextPutAll: printName, ' (', anInteger asString, ')'.
]

{ #category : #accessing }
DWARFEnumerationType >> typename [
	"enum does not have a name of its own. can be assigned one with typedef.
	Could return nil instead..."
	^ 'enum'.
]

{ #category : #printing }
DWARFEnumerationType >> valueToName: aValue [
   ^enumerators detect: [ :a | a value = aValue ] ifFound: #key ifNone: [nil].

]
