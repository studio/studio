Class {
	#name : #RJITRootTraceSet,
	#superclass : #Object,
	#instVars : [
		'location',
		'traces',
		'profile'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITRootTraceSet >> location [
	| root |
	root := traces detect: #isRootTrace ifNone: [ ^'?' ].
	^ root startLine.

]

{ #category : #accessing }
RJITRootTraceSet >> location: aLocation [
	location := aLocation
]

{ #category : #accessing }
RJITRootTraceSet >> numberOfRootTraces [
	^ traces count: #isRootTrace.

]

{ #category : #accessing }
RJITRootTraceSet >> numberOfSideTraces [
	^ traces count: #isSideTrace.

]

{ #category : #accessing }
RJITRootTraceSet >> profile: aRJITVMProfile [ 
	profile := aRJITVMProfile
]

{ #category : #accessing }
RJITRootTraceSet >> profiledTrace: tr [
	^ RJITTraceWithProfile new
		trace: tr;
		profile: (profile trace: tr);
		children: (traces select: [ :child | child parent = tr and: [ child isRootTrace not ] ]
								thenCollect: [ :child | self profiledTrace: child ]).

]

{ #category : #accessing }
RJITRootTraceSet >> profiledTraces [
	^ traces select: #isRootTrace thenCollect: [ :tr | self profiledTrace: tr ].

]

{ #category : #accessing }
RJITRootTraceSet >> samples [
	^ traces sum: [ :tr | (profile trace: tr) all ].
]

{ #category : #accessing }
RJITRootTraceSet >> traces [
	^ traces

]

{ #category : #accessing }
RJITRootTraceSet >> traces: aCollection [ 
	traces := aCollection
]
