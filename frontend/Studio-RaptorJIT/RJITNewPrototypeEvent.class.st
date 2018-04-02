Class {
	#name : #RJITNewPrototypeEvent,
	#superclass : #RJITEvent,
	#instVars : [
		'gcproto',
		'gcprotoAddress'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #initialization }
RJITNewPrototypeEvent >> asGCproto [
	^ flashback decodeGCprotoAt: gcprotoAddress.

]

{ #category : #initialization }
RJITNewPrototypeEvent >> from: dict flashback: aFlashback [ 
	flashback := aFlashback.
	gcprotoAddress := dict at: 'GCproto'.
]

{ #category : #printing }
RJITNewPrototypeEvent >> printOn: aStream [
	aStream
		nextPutAll: '<new_prototype: ';
		nextPutAll: self asGCproto sourceName;
		nextPutAll: '>'.
]
