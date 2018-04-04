Class {
	#name : #NixPackage,
	#superclass : #Object,
	#instVars : [
		'attrpath',
		'table'
	],
	#category : #'Studio-Nix'
}

{ #category : #accessing }
NixPackage >> attrpath [
	^ attrpath
]

{ #category : #accessing }
NixPackage >> attrpath: anObject [
	attrpath := anObject
]

{ #category : #accessing }
NixPackage >> gtInspectorItemsIn: composite [
	<gtInspectorPresentationOrder: 1>
	^ table gtInspectorItemsIn: composite.
]

{ #category : #accessing }
NixPackage >> printOn: aStream [
	super printOn: aStream.
	aStream 
		space;
		nextPut: $(;
		print: attrpath;
		nextPut: $).
]

{ #category : #accessing }
NixPackage >> spotterPreviewIn: aComposite [
	<spotterPreview: 10>
	^ aComposite table 
		title: 'Nix Package';
		display: [ | meta |
			meta := table at: 'meta'.
			{ 'attribute path' -> attrpath.
			  'name' -> (table at: 'name').
			  'description' -> (meta at: 'description' ifAbsent: ['(none)']).
			  'homepage' -> (meta at: 'homepage' ifAbsent: ['(none)']).
			  'longDescription' -> (meta at: 'longDescription' ifAbsent: ['(none)']).
			 } ];
		column: 'Field' evaluated: #key;
		column: 'Value' evaluated: #value;
		entity: self
]

{ #category : #accessing }
NixPackage >> table [
	^ table
]

{ #category : #accessing }
NixPackage >> table: anObject [
	table := anObject
]
