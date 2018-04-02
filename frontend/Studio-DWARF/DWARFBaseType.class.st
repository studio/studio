Class {
	#name : #DWARFBaseType,
	#superclass : #DWARFType,
	#instVars : [
		'name',
		'byteSize',
		'encoding',
		'accessingSelector'
	],
	#category : #'Studio-DWARF'
}

{ #category : #initialization }
DWARFBaseType >> accessingSelectorForEncoding: enc byteSize: size [
   (enc matchesRegex: '.*\(unsigned.*') ifTrue: [ 
	   size = 1 ifTrue: [ ^#unsignedByteAt: ].
	   size = 2 ifTrue: [ ^#unsignedShortAt: ].
	   size = 4 ifTrue: [ ^#unsignedLongAt: ].
	   size = 8 ifTrue: [ ^#unsignedLongLongAt: ]. ].
   (enc matchesRegex: '.*\(signed.*') ifTrue: [ 
	   size = 1 ifTrue: [ ^#signedByteAt: ].
	   size = 2 ifTrue: [ ^#signedShortAt: ].
	   size = 4 ifTrue: [ ^#signedLongAt: ].
	   size = 8 ifTrue: [ ^#signedLongLongAt: ]. ].
   (enc matchesRegex: '.*\(float\)') ifTrue: [ 
	   size = 4 ifTrue: [ ^#floatAt: ].
      size = 8 ifTrue: [ ^#doubleAt: ] ].

]

{ #category : #accessing }
DWARFBaseType >> byteSize [
	^ byteSize
]

{ #category : #decoding }
DWARFBaseType >> decode: aByteArray address: address flashback: flashback [
	^ DWARFValue type: self value: (aByteArray perform: accessingSelector with: 1)
	   address: address flashback: flashback.
]

{ #category : #initialization }
DWARFBaseType >> from: aCollection [
   name := aCollection at: 'name'. 
	byteSize := aCollection at: 'byte_size'.
	encoding := aCollection at: 'encoding'.
	accessingSelector := self accessingSelectorForEncoding: encoding byteSize: byteSize.

]

{ #category : #initialization }
DWARFBaseType >> icon [
   ^ Smalltalk ui iconNamed: #magnitude.
]

{ #category : #printing }
DWARFBaseType >> isBasic [
	^true
]

{ #category : #initialization }
DWARFBaseType >> name [
   ^ name
]

{ #category : #printing }
DWARFBaseType >> print: aValue on: aStream [
	aValue printOn: aStream.
]

{ #category : #initialization }
DWARFBaseType >> typename [
   ^name
]
