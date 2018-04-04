Class {
	#name : #DWARFPointerType,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'type',
		'byteSize'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFPointerType >> asInteger: anInteger [ 
	^ anInteger abs

]

{ #category : #accessing }
DWARFPointerType >> byteSize [
   ^ byteSize
]

{ #category : #accessing }
DWARFPointerType >> children: dwarfValue [
   ^(self hasChildren: dwarfValue)
      ifTrue: [
	      { '' -> (self dereference: dwarfValue). } ]
      ifFalse: [ {} ].

]

{ #category : #accessing }
DWARFPointerType >> decode: byteArray address: address flashback: flashback [
   | pointerAddress present |
   [ byteArray size = 8 ] assert. "XXX"
   pointerAddress := byteArray unsignedLongLongAt: 1.
   present := flashback includesAddress: pointerAddress byteSize: type byteSize.
   present ifFalse: [ pointerAddress := pointerAddress negated. ]. "missing pointer value is negative"
   ^DWARFValue type: self value: pointerAddress
               address: address flashback: flashback.
]

{ #category : #accessing }
DWARFPointerType >> dereference: dwarfValue [
	^dwarfValue flashback decodeType: type at: dwarfValue value abs.
]

{ #category : #'instance creation' }
DWARFPointerType >> from: dict via: references [
   byteSize := dict at: 'byte_size'.
   (dict includesKey: 'type')
      ifTrue: [ type := references at: (dict at: 'type') ]
      ifFalse: [ type := DWARFVoid ].
]

{ #category : #accessing }
DWARFPointerType >> hasChildren: dwarfValue [
	^ dwarfValue value > 0 and: type ~= DWARFVoid.
]

{ #category : #printing }
DWARFPointerType >> icon [
   ^ Smalltalk ui iconNamed: #glamorousUp.
]

{ #category : #printing }
DWARFPointerType >> print: anInteger on: aStream [
   aStream nextPutAll: type typename, ' @ 0x', (anInteger abs printStringBase: 16).

]

{ #category : #'instance creation' }
DWARFPointerType >> typename [
   ^ type typename , '*'.
]
