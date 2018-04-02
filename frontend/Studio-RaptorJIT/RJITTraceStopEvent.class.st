Class {
	#name : #RJITTraceStopEvent,
	#superclass : #RJITTraceEvent,
	#instVars : [
		'gctrace',
		'trace'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #decoding }
RJITTraceStopEvent >> decode [
	^flashback decodeTypeNamed: #GCtrace at: gctrace.

]

{ #category : #'instance creation' }
RJITTraceStopEvent >> from: dict flashback: aFlashback [
	super from: dict flashback: aFlashback.
   gctrace := dict at: 'GCtrace'.
	
]

{ #category : #testing }
RJITTraceStopEvent >> hasTrace [
	^ true.
]

{ #category : #printing }
RJITTraceStopEvent >> printOn: aStream [
	aStream nextPutAll: 'trace stop (success) from ', self startSourceLine, ' to ', self endSourceLine, ' (', self numberOfBytecodes asString, ' bytecodes)'
]
