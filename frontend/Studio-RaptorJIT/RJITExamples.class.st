Class {
	#name : #RJITExamples,
	#superclass : #Object,
	#classVars : [
		'process'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #api }
RJITExamples class >> all [
	^ {  self snabbmarkBasic1. }
]

{ #category : #internal }
RJITExamples class >> load [
	^ RaptorJIT loadUrl: self url.

]

{ #category : #internal }
RJITExamples class >> loadFromUrl: aUrl [
	^ RaptorJIT loadUrl: aUrl.
]

{ #category : #internal }
RJITExamples class >> snabbmarkBasic1 [
	^ RaptorJIT loadUrl: 'https://github.com/studio/example-data/raw/master/snabb/snabbmark-basic1-25003.tar.gz'

]

{ #category : #internal }
RJITExamples class >> url [
	self subclassResponsibility 
]

{ #category : #internal }
RJITExamples >> process [
	process ifNil: [ process :=  self class load. ].
	^ process.

]
