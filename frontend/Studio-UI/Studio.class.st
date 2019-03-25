Class {
	#name : #Studio,
	#superclass : #Object,
	#category : #'Studio-UI'
}

{ #category : #'instance creation' }
Studio class >> build: arg1 [
	^ [ :arg2 | 
	arg2 title: 'Studio backend is building data to inspect'.
	self doBuild: arg1 ] asJob run
]

{ #category : #'as yet unclassified' }
Studio class >> decodeFrom: inputDirectory to: outputDirectory [ 
	^ (RaptorJIT load: inputDirectory) textDumpInDirectory: outputDirectory.

]

{ #category : #accessing }
Studio class >> dir [
	^ Nix studioNixPath asFileReference
]

{ #category : #'instance creation' }
Studio class >> doBuild: arg1 [
	^ NixBuild onCode: arg1
]

{ #category : #'world menu' }
Studio class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #'Studio')
		order: 0;
		label: 'Studio';
		withSeparatorAfter.
]

{ #category : #'as yet unclassified' }
Studio class >> raptorjitProcess: arg1 [
	| tmp1 tmp2 |
	tmp1 := 'with import <studio>; raptorjit.inspect {1}'
		format: {arg1 asPath pathString}.
	tmp2 := self build: tmp1.
	^ RJITProcess new fromPath: tmp2 firstOutput
]

{ #category : #'as yet unclassified' }
Studio class >> raptorjitProcessList: arg1 [
	^ RJITProcessList
		withAll: (arg1 collect: [ :arg2 | self raptorjitProcess: arg2 ])
]
