"
I represent a list of RaptorJIT processes.

I make the processes easy to compare and inspect.
"
Class {
	#name : #RJITProcessList,
	#superclass : #OrderedCollection,
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
RJITProcessList >> profiles [
	^ RJITProfileList withAll: (self collect: #profile).
]
