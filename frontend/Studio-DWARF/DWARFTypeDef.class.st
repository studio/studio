Class {
	#name : #DWARFTypeDef,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'type'
	],
	#category : #'Studio-DWARF'
}

{ #category : #initialization }
DWARFTypeDef >> asInteger: dwarfValue [
	^ type asInteger: dwarfValue.

]

{ #category : #accessing }
DWARFTypeDef >> byteSize [
	^type byteSize.
]

{ #category : #initialization }
DWARFTypeDef >> childOf: dwValue named: aName [
	^ type childOf: dwValue named: aName.

]

{ #category : #initialization }
DWARFTypeDef >> children: dwarfValue [
	^ type children: dwarfValue.
]

{ #category : #decoding }
DWARFTypeDef >> decode: byteArray address: address flashback: flashback [
	^DWARFValue type: self value: (type decode: byteArray address: address flashback: flashback) value
	   address: address flashback: flashback.

]

{ #category : #initialization }
DWARFTypeDef >> from: dict via: references [
	name := dict at: 'name'.
	(dict includesKey: 'type') ifTrue: [ 
		type := references at: (dict at: 'type') ].
]

{ #category : #initialization }
DWARFTypeDef >> hasChildren: dwarfValue. [
	^ type hasChildren: dwarfValue.
]

{ #category : #printing }
DWARFTypeDef >> icon [
   ^ type icon.
]

{ #category : #printing }
DWARFTypeDef >> isBasic [
	^ type isBasic.
]

{ #category : #printing }
DWARFTypeDef >> print: value on: aStream [
	type print: value on: aStream.
]

{ #category : #initialization }
DWARFTypeDef >> typename [
   ^name
]

{ #category : #accessing }
DWARFTypeDef >> valueToName: anInteger [ 
	^type valueToName: anInteger.
]
