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
