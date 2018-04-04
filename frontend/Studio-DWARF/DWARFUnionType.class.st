Class {
	#name : #DWARFUnionType,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'byteSize',
		'members'
	],
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFUnionType >> byteSize [
	^ byteSize
]

{ #category : #'instance creation' }
DWARFUnionType >> childOf: dwValue named: aName [
	| values |
	values := self children: dwValue.
	1 to: members size do: [ :i | | member |
		member := members at: i.
		member name = aName ifTrue: [ ^values at: i ].
		member type isAnonymousStructure ifTrue: [
		(member type childOf: (values at: i) named: aName) ifNotNil: [ :x | ^x ]. ].
		].

]

{ #category : #'instance creation' }
DWARFUnionType >> children: dwarfValue [
   | values |
   values := dwarfValue value.
	^ (1 to: members size) collect: [ :i | (members at: i) name -> (values at: i) ].

]

{ #category : #'instance creation' }
DWARFUnionType >> decode: byteArray address: address flashback: flashback [
   [ byteSize notNil ] assert.
   ^DWARFValue type: self value: (members collect: [ :m |
	   m decode: byteArray address: address flashback: flashback. ])
      address: address flashback: flashback.

]

{ #category : #'instance creation' }
DWARFUnionType >> from: dict via: references [
	name := dict at: 'name' ifAbsent: [nil].
	byteSize := dict at: 'byte_size' ifAbsent: [nil].
	members := dict values select: #isDictionary 
	                       thenCollect: [ :x | DWARFMember new from: x via: references ].

]

{ #category : #'instance creation' }
DWARFUnionType >> hasChildren: dwarfValue [
	^ members size > 0.
]

{ #category : #'instance creation' }
DWARFUnionType >> icon [
   ^ Smalltalk ui iconNamed: #group.
]

{ #category : #'instance creation' }
DWARFUnionType >> print: value on: aStream [
   aStream nextPutAll: '<', self typename, '>'

]

{ #category : #'instance creation' }
DWARFUnionType >> typename [
	^ name isNil ifTrue: [ 'union' ] ifFalse: [ 'union ', name. ].
]
