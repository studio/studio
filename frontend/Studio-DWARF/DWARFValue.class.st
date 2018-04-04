Class {
	#name : #DWARFValue,
	#superclass : #Object,
	#instVars : [
		'value',
		'type',
		'address',
		'flashback'
	],
	#category : #'Studio-DWARF'
}

{ #category : #'as yet unclassified' }
DWARFValue class >> type: aType value: aValue address: address flashback: flashback [
   ^ self new type: aType; value: aValue; address: address; flashback: flashback; yourself.
]

{ #category : #accessing }
DWARFValue >> address [
   ^address
]

{ #category : #accessing }
DWARFValue >> address: anInteger [ 
	address := anInteger
]

{ #category : #accessing }
DWARFValue >> asInteger [
	^ type asInteger: value.

]

{ #category : #'as yet unclassified' }
DWARFValue >> associations [
	self shouldBeImplemented.
]

{ #category : #accessing }
DWARFValue >> byteSize [
	^ type byteSize.
]

{ #category : #accessing }
DWARFValue >> child: name [
	^type childOf: self named: name.

]

{ #category : #accessing }
DWARFValue >> children [
	^type children: self.
]

{ #category : #accessing }
DWARFValue >> dereference [
	^type dereference: self.

]

{ #category : #accessing }
DWARFValue >> dwarf [
   ^ flashback auditLog dwarf.
]

{ #category : #accessing }
DWARFValue >> flashback [
   ^flashback
]

{ #category : #accessing }
DWARFValue >> flashback: aFlashback [
   flashback := aFlashback.
]

{ #category : #accessing }
DWARFValue >> gtInspectorDWARFIn: composite [
	<gtInspectorPresentationOrder: 1>
	^ composite fastTreeTable
		title: 'DWARF';
		display: [ { '(root)' -> self. } ];
		column: 'Name' evaluated: [ :x | x key ];
		column: 'Value' evaluated: [ :x | x value ];
		column: 'Type' evaluated: [ :x | x value type typename ];
		column: 'Address' evaluated: [ :x | '0x', (x value address printStringBase: 16). ];
		hasChildren: [ :x | x value hasChildren ];
		children: [ :x | x value children ];
		icon: [ :x | x value type icon ];
		expandedUntil: 1.
]

{ #category : #testing }
DWARFValue >> hasChildren [
	^type hasChildren: self.
]

{ #category : #accessing }
DWARFValue >> printOn: aStream [
   type print: value on: aStream.
]

{ #category : #accessing }
DWARFValue >> type [
	^type
]

{ #category : #accessing }
DWARFValue >> type: aDWARFType. [
	type := aDWARFType.
]

{ #category : #accessing }
DWARFValue >> value [
	^value
]

{ #category : #accessing }
DWARFValue >> value: aValue [
   value := aValue.
]
