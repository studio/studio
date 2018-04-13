Class {
	#name : #RJITTraceWithProfile,
	#superclass : #Object,
	#instVars : [
		'trace',
		'profile',
		'children'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITTraceWithProfile >> children [
	^ children
]

{ #category : #accessing }
RJITTraceWithProfile >> children: aCollection [ 
	children := aCollection
]

{ #category : #accessing }
RJITTraceWithProfile >> gcPercent [
	^ profile gcPercent
]

{ #category : #accessing }
RJITTraceWithProfile >> linkname [
	^ trace linkname
]

{ #category : #accessing }
RJITTraceWithProfile >> linktype [
	^ trace linktype
]

{ #category : #accessing }
RJITTraceWithProfile >> location [
	^ self trace startLine.

]

{ #category : #accessing }
RJITTraceWithProfile >> mcodePercent [
	^ profile mcodePercent
]

{ #category : #accessing }
RJITTraceWithProfile >> profile: aRJITVMProfileTrace [ 
	profile := aRJITVMProfileTrace
]

{ #category : #accessing }
RJITTraceWithProfile >> samples [
	^ profile all.
]

{ #category : #accessing }
RJITTraceWithProfile >> trace [
	^ trace
]

{ #category : #accessing }
RJITTraceWithProfile >> trace: tr [
	trace := tr
]

{ #category : #accessing }
RJITTraceWithProfile >> traceno [
	^ trace traceno
]

{ #category : #accessing }
RJITTraceWithProfile >> vmPercent [
	^ profile vmPercent
]
