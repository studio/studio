Class {
	#name : #RJITUnknownEvent,
	#superclass : #RJITEvent,
	#instVars : [
		'dict'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #initializing }
RJITUnknownEvent >> from: aDict flashback: aFlashback [
	dict := aDict.
	flashback := aFlashback. 
]

{ #category : #printing }
RJITUnknownEvent >> printOn: aStream [
	aStream
		nextPutAll: '<event: ';
		nextPutAll: (dict at: #event);
		nextPutAll: '>'.
]
