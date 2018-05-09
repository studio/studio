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

{ #category : #accessing }
RJITPrototype >> declname [
	| ptr |
	ptr := (gcproto child: #declname) value.
	^ (ptr = nil or: [ ptr = 0 ]) ifTrue: [ nil ] ifFalse: [ ^ gcproto flashback decodeCStringAt: ptr ].

]

{ #category : #accessing }
RJITPrototype >> firstLine [
	^ firstline
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

{ #category : #initialization }
RJITPrototype >> sourceLine [
	^ self sourceLine: 0
]

{ #category : #'as yet unclassified' }
RJITPrototype >> sourceLine: position [
	^ self sourceName: (self bytecodeLine: position).

]

{ #category : #initialization }
RJITPrototype >> sourceLineShort [
	^ self sourceLineShort: 0

]

{ #category : #'as yet unclassified' }
RJITPrototype >> sourceLineShort: position [
	^ self sourceName: (self bytecodeLine: position) long: false.

]

{ #category : #accessing }
RJITPrototype >> sourceName [
	^ sourceName trimLeft: [ :x | x = $@ or: x = $= ]
]

{ #category : #accessing }
RJITPrototype >> sourceName: line [
	^ self sourceName: line long: true.
]

{ #category : #accessing }
RJITPrototype >> sourceName: line long: isLong [
	[
		| chunk declname functionLine |
		chunk := self sourceName.
		declname := self declname.
		functionLine := line - self firstLine + 1.
		declname
			ifNil: [ "limited debug information available (older RaptorJIT)"
				^ sourceName, ':', line asString ]
			ifNotNil: [ 
				declname ifEmpty: [ declname := '<anonymous>' ].
				^ isLong ifTrue: [
					'({1}){2}:{3} ({4}:{5})' format:
						{ chunk luaModuleName. declname. functionLine. chunk. line. } ]
					ifFalse: [ 
					'({1}){2}:{3}' format:
						{ chunk luaModuleName. declname. functionLine.} ]
						 ]
	] value. "ifCurtailed: [ ^ '?' ]."

]

{ #category : #'as yet unclassified' }
RJITPrototype >> sourcePC: programCounter [
	^ self sourceName: (self programCounterLine: programCounter).

]

{ #category : #'as yet unclassified' }
RJITPrototype >> sourcePCShort: programCounter [
	^ self sourceName: (self programCounterLine: programCounter) long: false.

]

{ #category : #'as yet unclassified' }
RJITPrototype >> upvalueName: index [
	| uvinfoPtr |
	uvinfoPtr := (gcproto child: #uvinfo) value value.
	^ gcproto flashback decodeCStringAt: uvinfoPtr + (index * 8).

]
