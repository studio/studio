Class {
	#name : #NixPkgs,
	#superclass : #Object,
	#instVars : [
		'nixpkgs'
	],
	#classInstVars : [
		'default'
	],
	#category : #'Studio-Nix'
}

{ #category : #'accessing instances and variables' }
NixPkgs class >> default [
	default := default ifNil: [ self new ].
	^default.

]

{ #category : #initialization }
NixPkgs >> packages [
	^nixpkgs
]

{ #category : #initialization }
NixPkgs >> scan [
	nixpkgs := self scanIntoJsonArray.

]

{ #category : #initialization }
NixPkgs >> scanIntoJsonArray [
	| p s aCollection |
	p := PipeableOSProcess command: '/Users/lukegorrie/.nix-profile/bin/nix-env -qa --attr-path --drv-path --description --meta --json'.
	s := p output.
	s = '' ifTrue: [  ^ self error: 'Could not run nix-env' ].
	aCollection := OrderedCollection new.
	(NeoJSONReader fromString: s) keysAndValuesDo: [ :key :value |
		aCollection add: (NixPackage new attrpath: key; table: value; yourself) ].
	^ aCollection

]
