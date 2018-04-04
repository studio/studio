Class {
	#name : #DWARFConstType,
	#superclass : #DWARFType,
	#instVars : [
		'type'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFConstType >> byteSize [
	^ type byteSize.
]

{ #category : #decoding }
DWARFConstType >> decode: byteArray address: address flashback: flashback [ 
	^DWARFValue type: self value: (type decode: byteArray address: address flashback: flashback) value
	   address: address flashback: flashback.
	
]

{ #category : #'instance creation' }
DWARFConstType >> from: dict via: references [
   (dict includesKey: 'type')
      ifTrue: [ type := references at: (dict at: 'type') ]
      ifFalse: [ type := DWARFVoid ].
]

{ #category : #'instance creation' }
DWARFConstType >> isBasic [
	^ type isBasic.
]

{ #category : #'instance creation' }
DWARFConstType >> typename [
	^ 'const ' , type typename.

]
