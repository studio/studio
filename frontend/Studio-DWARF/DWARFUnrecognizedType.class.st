Class {
	#name : #DWARFUnrecognizedType,
	#superclass : #DWARFType,
	#instVars : [
		'definition'
	],
	#category : #'Studio-DWARF'
}

{ #category : #'as yet unclassified' }
DWARFUnrecognizedType >> byteSize [
	^0
]

{ #category : #decoding }
DWARFUnrecognizedType >> decode: byteArray address: address flashback: flashback [
	^nil
]

{ #category : #initialization }
DWARFUnrecognizedType >> from: aCollection [ 
   definition := aCollection.

]

{ #category : #printing }
DWARFUnrecognizedType >> print: none on: aStream [
	[ none isNil ] assert.
	aStream nextPutAll: '<?>'.
]

{ #category : #initialization }
DWARFUnrecognizedType >> typename [
   ^'?'
]
