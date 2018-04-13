Class {
	#name : #RJITPrototype,
	#superclass : #Object,
	#instVars : [
		'gcproto',
		'firstline',
		'lineinfo',
		'sourceName'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'as yet unclassified' }
RJITPrototype >> bytecodeLine: position [
	^ (self lineinfo at: position + 1).
]

{ #category : #'as yet unclassified' }
RJITPrototype >> bytecodeValue: position [
	^ self bytecodeValues at: position + 1.

]

{ #category : #accessing }
RJITPrototype >> bytecodeValues [
	| array size |
	array := gcproto address + gcproto type byteSize.
	size := (gcproto child: #sizebc) value.
	^ (0 to: size-1) collect: [ :ix |
		(gcproto flashback decodeTypeNamed: #uint32_t at: array + (ix*4)) value ].

]

{ #category : #'instance creation' }
RJITPrototype >> from: aGCproto [
	gcproto := aGCproto.
	firstline := (aGCproto child: #firstline) value.
	sourceName := gcproto flashback decodeLuaStringAt: (gcproto child: #chunkname).
]

{ #category : #accessing }
RJITPrototype >> lineinfo [
	| array size |
	lineinfo ifNotNil: [ ^ lineinfo ].
	array := (gcproto child: #lineinfo) asInteger.
	size := (gcproto child: #sizebc) value.
	lineinfo := (0 to: size-1) collect: [ :ix |
		(gcproto flashback decodeTypeNamed: #uint32_t at: array + (ix*4)) value ].	
	^ lineinfo
]

{ #category : #'as yet unclassified' }
RJITPrototype >> programCounterLine: pc [
	| position |
	position := pc value - (gcproto address + gcproto byteSize) / 4.
	^ self bytecodeLine: position.

]

{ #category : #accessing }
RJITPrototype >> sourceName [
	^ sourceName trimLeft: [ :x | x = $@ or: x = $= ]
]

{ #category : #'as yet unclassified' }
RJITPrototype >> upvalueName: index [
	| uvinfoPtr |
	uvinfoPtr := (gcproto child: #uvinfo) value value.
	^ gcproto flashback decodeCStringAt: uvinfoPtr + (index * 8).

]
