Class {
	#name : #DWARFArrayType,
	#superclass : #DWARFType,
	#instVars : [
		'elementSize',
		'numberOfElements',
		'elementType'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFArrayType >> byteSize [
	"XXX not sure if elementSize is correctly decoded."
	^ numberOfElements * (elementSize ifNil: elementType byteSize).
]

{ #category : #printing }
DWARFArrayType >> children: dwarfValue [
   ^ (0 to: numberOfElements - 1) collect: [ :i | i -> (dwarfValue value at: i + 1). ].
]

{ #category : #'instance creation' }
DWARFArrayType >> decode: byteArray address: address flashback: flashback [
   | elements |
	elements := (0 to: numberOfElements - 1) collect: [ :i | | eachSize offset bytes |
		eachSize := elementSize ifNil: elementType byteSize.
		offset := eachSize * i.
		bytes := byteArray copyFrom: offset + 1 to: offset + elementType byteSize.
		elementType decode: bytes address: address flashback: flashback. ].
	^ DWARFValue type: self value: elements address: address flashback: flashback.
]

{ #category : #'instance creation' }
DWARFArrayType >> from: dict via: references [
	| spec |
	elementSize := dict at: 'byte_size' ifAbsent: [nil]. "XXX find example where this is present"
	spec := dict detect: [ :x | x isDictionary ].
	numberOfElements := (spec includesKey: 'upper_bound') ifTrue: [ (spec at: 'upper_bound') + 1 ] ifFalse: [nil].
	elementType := references at: (dict at: 'type').
]

{ #category : #printing }
DWARFArrayType >> hasChildren: dwarfValue [
	^ numberOfElements > 0.
]

{ #category : #printing }
DWARFArrayType >> icon [
   ^ Smalltalk ui iconNamed: #collection.
]

{ #category : #printing }
DWARFArrayType >> print: aValue on: aStream [
   aStream nextPutAll: '<', self typename, '>'.
]

{ #category : #printing }
DWARFArrayType >> typename [
	^ elementType typename, '[', (numberOfElements ifNil: '') asString, ']'.
]
