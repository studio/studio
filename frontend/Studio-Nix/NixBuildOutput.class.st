Class {
	#name : #NixBuildOutput,
	#superclass : #Object,
	#instVars : [
		'fileReference',
		'products'
	],
	#category : #'Studio-Nix'
}

{ #category : #'as yet unclassified' }
NixBuildOutput class >> onFileReference: ref [
	self new fileReference: ref.
]

{ #category : #accessing }
NixBuildOutput >> fileReference: ref [
	fileReference := ref.
	products := self inspect: fileReference.
]
