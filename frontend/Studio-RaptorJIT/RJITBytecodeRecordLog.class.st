Class {
	#name : #RJITBytecodeRecordLog,
	#superclass : #Object,
	#instVars : [
		'bytecodes'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #converting }
RJITBytecodeRecordLog >> bytecodeListing [
	^ String streamContents: [ :s |
		bytecodes select: [ :bc | bc framedepth isNotNil ] thenDo: [ :bc |
			s nextPutAll: bc bytecodeListingLine; cr. ] ].

]

{ #category : #accessing }
RJITBytecodeRecordLog >> bytecodes [
	^ bytecodes select: [ :bc | bc opcode isNotNil ].
]

{ #category : #initialization }
RJITBytecodeRecordLog >> from: aCollectionOfBytecodes [
	bytecodes := aCollectionOfBytecodes.

]

{ #category : #accessing }
RJITBytecodeRecordLog >> gtBytecodesFor: aView [
	<gtView>
	| aList |
	aList := aView columnedList
		title: 'Bytecode Log' translated;
		priority: 20;
		items: [ self bytecodes ].
	aList column
		title: 'Index' translated;
		width: 60;
		item: [ :item :index | index ].
	aList column
		title: 'Depth' translated;
		width: 60;
		item: [ :item :index | item framedepth ].
	aList column
		title: 'Opcode' translated;
		width: 60;
		item: [ :item :index | item opcodeName ].
	aList column
		title: 'Source line' translated;
		weight: 1;
		item: [ :item :index | item sourceLine ].
	^ aList
]

{ #category : #accessing }
RJITBytecodeRecordLog >> gtInspectorBytecodesIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite fastTable
		title: 'Bytecodes';
		display: [ self bytecodes ];
		addAction: [ self bytecodeListing ] gtInspectorActionCopyValueToClipboard;
		enableElementIndex;
		column: 'Index' evaluated: [ :x :idx | idx ] width: 60;
		column: 'Depth' evaluated: #framedepth width: 60;
		column: 'Opcode' evaluated: #opcodeName width: 60;
		column: 'Line' evaluated: #sourceLine width: 250.

]
