Class {
	#name : #StudioInspector,
	#superclass : #GTInspector,
	#category : #'Studio-UI'
}

{ #category : #'instance creation' }
StudioInspector class >> open [
	| inspector |
	inspector := self new.
	inspector
		showFirst: [ :composite |
			composite text
				title: 'Nix expression';
				populate: #selection iconName: #glamorousGo on: $G entitled: 'Build' with: [ :editor |
					inspector go: editor text asString withUnixLineEndings. ] ].
	^inspector openOn: 'with import <studio>;
'.
]

{ #category : #'scripting opening' }
StudioInspector >> go: code [
	[ :job |
		| product |
		job title: 'Studio backend is building the Nix expression'.
		product := [ NixBuild onCode: code ] on: NixError do: [ :error |
			| dialog |
			dialog := NixErrorWindow openWithMessage: error messageText.
			dialog window
				position: self window position + (self window extent * 0.05);
				extent: self window extent * 0.9.
			^ nil ].
		job title: 'Studio frontend is loading the product build by the backend'.
		^ RJITProcess new fromPath: product firstOutput.
	] asJob run.

]

{ #category : #'scripting opening' }
StudioInspector >> open [
	| window |
	window := self openOn: StudioWelcome new.
	self browser selection: 42.
	^window.
]
