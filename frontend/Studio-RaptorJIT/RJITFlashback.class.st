Class {
	#name : #RJITFlashback,
	#superclass : #Object,
	#instVars : [
		'auditLog',
		'previous',
		'address',
		'data',
		'hint',
		'index',
		'time',
		'image'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITFlashback >> address [
	^ address
]

{ #category : #accessing }
RJITFlashback >> address: anObject [
	address := anObject
]

{ #category : #accessing }
RJITFlashback >> asIrModes [
	"Special case: decode lj_ir_mode as a uint8_t array."
	^ ((0 to: data size - 1) collect: [ :i |
		i -> (RJITIRMode new from: (data at: i+1)) ]) asDictionary.
]

{ #category : #accessing }
RJITFlashback >> asOrderedCollection [
	| c o |
	c := OrderedCollection new.
	o := self.
	[ o ] whileNotNil: [ c add: o. o := o previous. ].
	^ c.
]

{ #category : #accessing }
RJITFlashback >> auditLog [
	^auditLog.
]

{ #category : #accessing }
RJITFlashback >> auditLog: anAuditLog [
	auditLog := anAuditLog.
]

{ #category : #accessing }
RJITFlashback >> byteAt: byteAddress [
	^ (self bytesAt: byteAddress size: 1) first.

]

{ #category : #accessing }
RJITFlashback >> bytesAt: anAddress size: size [
	^ image getBytes: size atAddress: anAddress atTime: time.

]

{ #category : #accessing }
RJITFlashback >> data [
	^ data
]

{ #category : #accessing }
RJITFlashback >> data: anObject [
	data := anObject
]

{ #category : #decoding }
RJITFlashback >> decodeArrayOfTypeNamed: typename at: anAddress elements: elems [
	| type |
	type := (auditLog dwarf typeNamed: typename).
	^ (0 to: elems - 1) collect: [ :ix |
		| elementAddress |
		elementAddress := anAddress asInteger + (ix * type byteSize).
		self decodeType: type at: elementAddress ].

]

{ #category : #decoding }
RJITFlashback >> decodeGCobjectAt: anAddress [
	| gcobj |
	gcobj := self decodeTypeNamed: #GCobj at: anAddress.

]

{ #category : #decoding }
RJITFlashback >> decodeGCprotoAt: anAddress [
	^ RJITPrototype new from: (self decodeTypeNamed: #GCproto at: anAddress asInteger).

]

{ #category : #decoding }
RJITFlashback >> decodeJITStateAt: anAddress [
	^ RJITJITState new from: (self decodeTypeNamed: #jit_State at: anAddress asInteger).

]

{ #category : #decoding }
RJITFlashback >> decodeLuaStringAt: anAddress [
	| gcstr |
	gcstr := self decodeTypeNamed: #GCstr at: anAddress asInteger.
	^ self decodeStringAt: (gcstr address + gcstr type byteSize) size: (gcstr child: #len) value.
]

{ #category : #accessing }
RJITFlashback >> decodeStringAt: anAddress size: size [
	^ (self bytesAt: anAddress size: size) asString

]

{ #category : #decoding }
RJITFlashback >> decodeType: type at: anAddress [
	^ type decode: (self bytesAt: anAddress size: type byteSize)
	   address: anAddress flashback: self.
]

{ #category : #decoding }
RJITFlashback >> decodeTypeNamed: typename at: anAddress [
   ^ self decodeType: (auditLog dwarf typeNamed: typename) at: anAddress.

]

{ #category : #accessing }
RJITFlashback >> hint [
	^ hint
]

{ #category : #accessing }
RJITFlashback >> hint: anObject [
	hint := anObject
]

{ #category : #accessing }
RJITFlashback >> image [
	^ image
]

{ #category : #accessing }
RJITFlashback >> includes: byteAddress [
	^ self includesAddress: byteAddress byteSize: 1.

]

{ #category : #accessing }
RJITFlashback >> includesAddress: anAddress byteSize: size [
	[ self bytesAt: anAddress size: size ] on: RJITFlashbackDataMissing do: [ ^ false ].
	^ true.

]

{ #category : #accessing }
RJITFlashback >> index [
	^ index
]

{ #category : #initialization }
RJITFlashback >> initialize [

	super initialize.

	index := 0.
	address := nil.
	data := nil.
	hint := nil.
	previous := nil.
]

{ #category : #accessing }
RJITFlashback >> irConstantFrom: anInteger [ 
	self shouldBeImplemented.
]

{ #category : #accessing }
RJITFlashback >> irInstructionAt: anAddress [
	^RJITIRInstruction new irIns: (self decodeTypeNamed: #IRIns at: anAddress).
]

{ #category : #accessing }
RJITFlashback >> irInstructionAt: anAddress index: i [
	^RJITIRInstruction new
		irIns: (self decodeTypeNamed: #IRIns at: anAddress);
		index: i;
		yourself.
]

{ #category : #accessing }
RJITFlashback >> irOperandModeFor: irOpcode [ 
	^ self irOperandModes at: irOpcode.

]

{ #category : #accessing }
RJITFlashback >> irOperandModes [
	self shouldBeImplemented.
]

{ #category : #accessing }
RJITFlashback >> loadBytesAt: anAddress into: anArray index: anIndex limit: aLimit [
	| start end |
	start := address.
	end := address + data size.
	anIndex >= anArray size ifTrue: [ ^ anIndex ]. "Complete."
	anAddress + anIndex > aLimit ifTrue: [ ^anIndex ]. "Backtrack."
	(anAddress + anIndex >= start and: anAddress + anIndex < end)
		ifTrue: [ 
			"Load the first byte."
			anArray at: anIndex + 1 put: (data at: anAddress + anIndex - start + 1).
			"Recurse for more."
			^ self loadBytesAt: anAddress into: anArray index: anIndex + 1 limit: aLimit. ]
		ifFalse: [ 
			"Search for a matching flashback."
			previous
				ifNil: [
					^ anIndex ]
				ifNotNil: [
					| newLimit |
					newLimit := start > anAddress ifTrue: [ aLimit min: start ] ifFalse: [ aLimit ].
					^ previous loadBytesAt: anAddress into: anArray index: anIndex limit: newLimit ] ].

]

{ #category : #accessing }
RJITFlashback >> previous [
	^ previous
]

{ #category : #accessing }
RJITFlashback >> previous: anObject [
	previous := anObject.
	previous ifNotNil: [ index := previous index + 1 ].
]

{ #category : #initialization }
RJITFlashback >> setup [
	"Setup linkage to earlier flashbacks (if any.)"
	previous
		ifNil: [ 
			time := 0.
			image := RJITFlashbackImage new. ]
		ifNotNil: [ 
			time := previous time + 1.
			image := previous image. ].
	"Store data."
	image setBytes: data atAddress: address atTime: time.
]

{ #category : #decoding }
RJITFlashback >> sizeOfTypeNamed: typename [
	^ (auditLog dwarf typeNamed: typename) byteSize.
]

{ #category : #accessing }
RJITFlashback >> time [
	^ time
]
