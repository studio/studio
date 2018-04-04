Class {
	#name : #RJITEvent,
	#superclass : #Object,
	#instVars : [
		'jitState',
		'flashback',
		'number'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITEvent >> endSourceLine [
	self numberOfBytecodes = 0 ifTrue: [ ^'?' ].
	^ self jitState bytecodes last sourceLine.
]

{ #category : #accessing }
RJITEvent >> flashback: aFlashback [
	flashback := aFlashback.
]

{ #category : #accessing }
RJITEvent >> gtInspectorBytecodesIn: composite [
	<gtInspectorPresentationOrder: 1>
	self jitState ifNil: [ ^nil ].
	self jitState gtInspectorBytecodesIn: composite.

]

{ #category : #accessing }
RJITEvent >> gtInspectorInfoIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite fastTable
		title: 'Info';
		display: [ self info ];
		column: 'Name' evaluated: #key width: 100;
		column: 'Value' evaluated: #value width: 600.

]

{ #category : #accessing }
RJITEvent >> hasTrace [
	^ false
]

{ #category : #accessing }
RJITEvent >> info [
	"Answer a collection of associations with key:value information."
	| info |
	info := OrderedCollection new.
	self jitState ifNotNil: [
		self jitState bytecodes size > 0 ifTrue: [ 
			info add: 'start' -> self startSourceLine.
			info add: 'end'   -> self endSourceLine.
		].
		info add: '#bytecodes' -> self numberOfBytecodes.
	 ].
	^ info
]

{ #category : #testing }
RJITEvent >> isTraceEvent [
	^ false
]

{ #category : #accessing }
RJITEvent >> jitState [
	^ jitState
]

{ #category : #accessing }
RJITEvent >> number: anInteger [ 
	number := anInteger
]

{ #category : #accessing }
RJITEvent >> numberOfBytecodes [
	^ self jitState bytecodes size.
]

{ #category : #accessing }
RJITEvent >> startSourceLine [
	^ jitState startSourceLine.

]
