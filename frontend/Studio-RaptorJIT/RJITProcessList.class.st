"
I represent a list of RaptorJIT processes.

I make the processes easy to compare and inspect.
"
Class {
	#name : #RJITProcessList,
	#superclass : #OrderedCollection,
	#instVars : [
		'path'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'inspector extensions' }
RJITProcessList >> gtProcessesFor: aView [
	<gtView>
	| profiles |
	profiles := RJITProfileList withAll: (self collect: #profile).
	^ profiles subjectViewTitled: 'Processes' translated subjectName: 'Process' translated onView: aView.
	
]

{ #category : #accessing }
RJITProcessList >> path [
	^ path
]

{ #category : #accessing }
RJITProcessList >> path: aPath [
	path := aPath
]

{ #category : #accessing }
RJITProcessList >> profiles [
	^ RJITProfileList withAll: (self collect: #profile).
]

{ #category : #testing }
RJITProcessList >> test [
	^ self collect: #test
]
