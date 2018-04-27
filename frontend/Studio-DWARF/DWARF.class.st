Class {
	#name : #DWARF,
	#superclass : #Object,
	#instVars : [
		'types',
		'json',
		'alltypes'
	],
	#category : #'Studio-DWARF'
}

{ #category : #'instance creation' }
DWARF class >> loadFromFileNamed: fileName [
	^self new loadFromFileNamed: fileName.
]

{ #category : #initializing }
DWARF >> dwarfTypeOf: dict via: references [
	| tag |
	tag := dict at: 'tag'.
	tag = 'base_type' ifTrue: [ ^DWARFBaseType new from: dict. ].
	tag = 'typedef' ifTrue: [ ^DWARFTypeDef new from: dict via: references. ].
	tag = 'pointer_type' ifTrue: [ ^DWARFPointerType new from: dict via: references. ].
	tag = 'const_type' ifTrue: [ ^ DWARFConstType new from:dict via: references. ].
	tag = 'structure_type' ifTrue: [ ^DWARFStructureType new from: dict via: references. ].
	tag = 'enumeration_type' ifTrue: [ ^DWARFEnumerationType new from: dict via: references. ].
	tag = 'array_type' ifTrue: [ ^DWARFArrayType new from: dict via: references. ].
	tag = 'union_type' ifTrue: [ ^DWARFUnionType new from: dict via: references. ].
	^DWARFUnrecognizedType new from: dict.
]

{ #category : #accessing }
DWARF >> enumerationTypeWith: aName [
  ^alltypes detect: [ :t | t isEnumeration and: [ t includesName: aName ] ].

]

{ #category : #initialization }
DWARF >> loadFromBinaryFileNamed: fileName [
	| res |
	[
		res := Nix build: 'with import <studio>; dwarfish.elf2json ', fileName.
	] asJob title: 'Preprocessing DWARF definitions'; run.
	self loadFromFileNamed: res first.

]

{ #category : #initialization }
DWARF >> loadFromByteArray: array [
	| tmp |
	tmp := FileReference newTempFilePrefix: 'dwarf-' suffix: '.dwo'.
	tmp writeStream binary nextPutAll: array; close.
	self loadFromBinaryFileNamed: tmp pathString.
]

{ #category : #initialization }
DWARF >> loadFromFileNamed: fileName [
	| references  |
	json := (NeoJSONReader on: (FileStream readOnlyFileNamed: fileName)) next.
	"References is a tag->object mapping where each object will #become: the real type."
	references := json collect: [ :_ | Object new ].
	alltypes := json collect: [ :dict | self dwarfTypeOf: dict via: references ].
	"Walk the heap and replace reference objects with real type objects."
	references values elementsForwardIdentityTo: (references keys collect: [ :tag | alltypes at: tag]).
	types := Dictionary new.
	alltypes do: [ :type |
		| name |
		name := type typename asSymbol.
		(types includesKey: name) ifFalse: [ types at: name put: type ] ].
]

{ #category : #initializing }
DWARF >> resolveConstant: name [
	alltypes select: #isEnumeration
			thenDo: [ :e | (e nameToValue: name) ifNotNil: [ :value | ^value ]. ].
	^nil.

]

{ #category : #accessing }
DWARF >> typeNamed: typename [
	^ types at: typename.

]

{ #category : #initializing }
DWARF >> valueToName: aValue inEnumerationWith: aName [
   ^ (self enumerationTypeWith: aName) valueToName: aValue.
]
