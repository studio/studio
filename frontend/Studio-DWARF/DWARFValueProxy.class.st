Class {
	#name : #DWARFValueProxy,
	#superclass : #Object,
	#instVars : [
		'dwarfValue'
	],
	#category : #'Studio-DWARF'
}

{ #category : #'instance creation' }
DWARFValueProxy class >> on: aDWARFValue [
   ^ self new dwarfValue: aDWARFValue.
]

{ #category : #accessing }
DWARFValueProxy >> asInteger [
	^ self dwarfValue asInteger.

]

{ #category : #accessing }
DWARFValueProxy >> at: name [
	(dwarfValue children at: name) simplify.

]

{ #category : #accessing }
DWARFValueProxy >> at: name ifAbsent: aBlock [
   ^ (DWARFValueProxy on: ((dwarfValue child: name) ifNil: [ ^aBlock value ])) simplify.

]

{ #category : #accessing }
DWARFValueProxy >> doesNotUnderstand: message [
   ^self at: message selector ifAbsent: [ ^super doesNotUnderstand: message ].
]

{ #category : #accessing }
DWARFValueProxy >> dwarfValue [
	^ dwarfValue
]

{ #category : #accessing }
DWARFValueProxy >> dwarfValue: anObject [
	dwarfValue := anObject
]

{ #category : #accessing }
DWARFValueProxy >> flashback [
	^self dwarfValue flashback.
]

{ #category : #accessing }
DWARFValueProxy >> gtInspectorDWARFIn: composite [
	<gtInspectorPresentationOrder: 1>
	self dwarfValue gtInspectorDWARFIn: composite.
]

{ #category : #accessing }
DWARFValueProxy >> printOn: aStream [
   super printOn: aStream.
   aStream nextPutAll: ' on '.
   dwarfValue printOn: aStream.
]

{ #category : #accessing }
DWARFValueProxy >> simplify [
	^ dwarfValue type isBasic ifTrue: [ dwarfValue value ] ifFalse: [ self ].
]

{ #category : #accessing }
DWARFValueProxy >> value [
	^self dwarfValue value.
]
