Class {
	#name : #RJITJITState,
	#superclass : #Object,
	#instVars : [
		'jitState',
		'bytecodes'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #initialization }
RJITJITState >> bytecodeRecordLog [
	^ RJITBytecodeRecordLog new from: self bytecodes.

]

{ #category : #initialization }
RJITJITState >> bytecodes [
	| raw |
	bytecodes ifNotNil: [ ^bytecodes ].
	raw := self flashback
						decodeArrayOfTypeNamed: 'BCRecLog'
						at: jitState bclog
						elements: jitState nbclog.
	bytecodes := raw collect: [ :bc | RJITBytecode new from: bc ].
	^bytecodes.
]

{ #category : #'as yet unclassified' }
RJITJITState >> currentTrace [
	^ RJITTrace new from: jitState cur dwarfValue withExistingTraces: jitState flashback auditLog traces.
]

{ #category : #accessing }
RJITJITState >> flashback [
	^ jitState dwarfValue flashback.
]

{ #category : #initialization }
RJITJITState >> from: aJitState [
	jitState := DWARFValueProxy on: aJitState.
]

{ #category : #accessing }
RJITJITState >> gtBytecodesFor: aView [
	<gtView>
	^ self bytecodeRecordLog gtBytecodesFor: aView.

]

{ #category : #accessing }
RJITJITState >> gtInspectorBytecodesIn: composite [
	<gtInspectorPresentationOrder: 5>
	self bytecodeRecordLog gtInspectorBytecodesIn: composite.

]

{ #category : #initialization }
RJITJITState >> isFinal [
	Transcript show: jitState final printString.
	^ jitState final ~= 0.
]

{ #category : #'as yet unclassified' }
RJITJITState >> parentTraceno [
	^ jitState parent.
]

{ #category : #accessing }
RJITJITState >> startPrototype [
	^ jitState flashback decodeGCprotoAt: jitState cur startpt.

]

{ #category : #accessing }
RJITJITState >> startSourceLine [
	| pt line |
	pt := self startPrototype.
	line := pt programCounterLine: jitState cur startpc.
	^ pt sourceName, ':', line asString.
]

{ #category : #accessing }
RJITJITState >> startpc [
	^ jitState cur startpc.

]
