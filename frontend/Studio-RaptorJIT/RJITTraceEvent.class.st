Class {
	#name : #RJITTraceEvent,
	#superclass : #RJITEvent,
	#category : #'Studio-RaptorJIT'
}

{ #category : #initializating }
RJITTraceEvent >> from: dict flashback: aFlashback [
   flashback := aFlashback.
   jitState := flashback decodeJITStateAt: (dict at: 'jit_State').

]

{ #category : #'as yet unclassified' }
RJITTraceEvent >> gcTraceWithExistingTraces: traces [
	trace := RJITTrace new from: self decode withExistingTraces: traces; jitState: jitState.
	^ trace.
]

{ #category : #'gt-inspector-extension' }
RJITTraceEvent >> gtInspectorIRTreeIn: composite [
	"<gtInspectorPresentationOrder: 7>"
	"XXX Failing with a decoding error. Have to troubleshoot before enabling this view."
	self trace gtInspectorIRTreeIn: composite.
]

{ #category : #testing }
RJITTraceEvent >> isTraceEvent [
	^ true
]

{ #category : #'as yet unclassified' }
RJITTraceEvent >> parentTrace [
	^ jitState currentTrace
]

{ #category : #tracing }
RJITTraceEvent >> trace [
	^ jitState currentTrace.
]
