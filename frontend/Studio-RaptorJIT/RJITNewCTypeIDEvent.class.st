Class {
	#name : #RJITNewCTypeIDEvent,
	#superclass : #RJITEvent,
	#instVars : [
		'id',
		'desc'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITNewCTypeIDEvent >> desc [
	^ desc
]

{ #category : #initialization }
RJITNewCTypeIDEvent >> from: dict flashback: aFlashback [
	flashback := aFlashback.
	id := dict at: #id.
	desc := dict at: #desc.
]

{ #category : #accessing }
RJITNewCTypeIDEvent >> id [
	^ id
]
