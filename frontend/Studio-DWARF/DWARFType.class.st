Class {
	#name : #DWARFType,
	#superclass : #Object,
	#category : #'Studio-DWARF'
}

{ #category : #printing }
DWARFType >> childOf: dwValue named: aName [
	^ (self children: dwValue value) asDictionary at: aName ifAbsent: [nil].

]

{ #category : #printing }
DWARFType >> children: value [
	^ {}.
]

{ #category : #printing }
DWARFType >> hasChildren: value [
	^false.
]

{ #category : #printing }
DWARFType >> icon [
   ^nil
]

{ #category : #printing }
DWARFType >> isAnonymousStructure [
	^false
]

{ #category : #printing }
DWARFType >> isBasic [
	^false
]

{ #category : #printing }
DWARFType >> isEnumeration [
	^false
]

{ #category : #printing }
DWARFType >> print: aValue on: aStream [
   aStream nextPutAll: '<', self printString, '>'.
]

{ #category : #printing }
DWARFType >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' (', self typename, ')'.

]

{ #category : #printing }
DWARFType >> typename [
	^self subclassResponsibility.
]
