Class {
	#name : #Studio,
	#superclass : #Object,
	#category : #'Studio-Nix'
}

{ #category : #'as yet unclassified' }
Studio class >> decodeFrom: inputDirectory to: outputDirectory [
	| preprocessed |
	preprocessed := (Nix build: 'with import <studio>; raptorjit.inspect ', inputDirectory pathString)
							first asFileReference.
	RJITProcess new fromPath: preprocessed; textDumpInDirectory: outputDirectory.
]
