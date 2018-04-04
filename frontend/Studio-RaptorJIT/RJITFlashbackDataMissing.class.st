Class {
	#name : #RJITFlashbackDataMissing,
	#superclass : #Error,
	#instVars : [
		'address'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITFlashbackDataMissing >> address: anInteger [ 
	address := anInteger.
]
