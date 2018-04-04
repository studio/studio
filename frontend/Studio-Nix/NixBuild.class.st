Class {
	#name : #NixBuild,
	#superclass : #Object,
	#instVars : [
		'code',
		'derivations',
		'builds',
		'outputs'
	],
	#category : #'Studio-Nix'
}

{ #category : #'as yet unclassified' }
NixBuild class >> onCode: code [
	^ self new code: code; run; yourself.
]

{ #category : #accessing }
NixBuild >> code: codeString [
	code := codeString.
]

{ #category : #accessing }
NixBuild >> firstOutput [
	^ outputs first
]

{ #category : #accessing }
NixBuild >> gtInspectorOutputsIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite list title: 'Outputs'; display: outputs.

]

{ #category : #accessing }
NixBuild >> run [
	outputs := (Nix build: code) collect: #asFileReference.
]
