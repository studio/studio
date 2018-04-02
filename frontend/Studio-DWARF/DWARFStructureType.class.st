Class {
	#name : #DWARFStructureType,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'byteSize',
		'members'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFStructureType >> byteSize [
	^ byteSize
]

{ #category : #decoding }
DWARFStructureType >> childOf: dwValue named: aName [
	| value |
	value := super childOf: dwValue named: aName. "block -> value"
	^ value.
	"^ value ifNotNil: [ value value ]."
	
]

{ #category : #decoding }
DWARFStructureType >> children: dwarfValue [
   | values |
   values := dwarfValue value.
	^ (1 to: members size) collect: [ :i | (members at: i) name -> (values value at: i) value ].

]

{ #category : #decoding }
DWARFStructureType >> decode: byteArray address: address flashback: flashback [
   [ byteSize notNil ] assert.
   ^DWARFValue
		type: self
		value: (members collect: [ :m |
			"This elaborate use of square brackets is meant as a simple way to
			 memoize the member decoding by caching the first value in a closure.
			 Maybe weird to do it this way in Smalltalk? It would be fairly idiomatic
			 Common Lisp:
				(let ((cache nil))
				  (lambda ()
			 	   (or cache (setf cache (do-something-expensive)))))
			"
			[ | value |
				[ value ifNil: [
					value := m decode: byteArray address: address flashback: flashback.
					value ] ] ] value.
		])
      address: address
		flashback: flashback.

]

{ #category : #initialization }
DWARFStructureType >> from: dict via: references [
	name := dict at: 'name' ifAbsent: [nil].
	byteSize := dict at: 'byte_size' ifAbsent: [nil].
	members := dict values select: #isDictionary 
	                       thenCollect: [ :x | DWARFMember new from: x via: references ].

]

{ #category : #initialization }
DWARFStructureType >> hasChildren: dwarfValue [
	^ members size > 0.
]

{ #category : #initialization }
DWARFStructureType >> icon [
   ^ Smalltalk ui iconNamed: #glamorousTable.
]

{ #category : #initialization }
DWARFStructureType >> isAnonymousStructure [
	^ name = nil.
]

{ #category : #printing }
DWARFStructureType >> print: value on: aStream [
   aStream nextPutAll: '<', self typename, '>'

]

{ #category : #initialization }
DWARFStructureType >> typename [
	^ name isNil ifTrue: [ 'struct' ] ifFalse: [ 'struct ', name. ].
]
