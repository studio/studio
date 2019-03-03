Class {
	#name : #StudioInspector,
	#superclass : #GTInspector,
	#category : #'Studio-UI'
}

{ #category : #'instance creation' }
StudioInspector class >> open [
	| tmp1 |
	tmp1 := self new.
	tmp1
		showFirst: [ :arg1 | 
			| tmp3 |
			tmp3 := arg1 text.
			tmp3
				title: 'Nix expression';
				populate: #selection
					iconName: #glamorousGo
					on: $G
					entitled: 'Build'
					with: [ :arg2 | tmp1 go: arg2 text asString withUnixLineEndings ] ].
	^ tmp1
		openOn:
			'with import <studio>;
'
]

{ #category : #'scripting opening' }
StudioInspector >> go: arg1 [
	[ :arg2 | 
	| tmp1 |
	arg2 title: 'Studio backend is building data to inspect'.
	tmp1 := [ NixBuild onCode: arg1 ]
		on: NixError
		do: [ :arg3 | 
			| tmp2 tmp4 |
			tmp2 := NixErrorWindow openWithMessage: arg3 messageText.
			tmp4 := tmp2 window.
			tmp4
				position: self window position + (self window extent * 0.05);
				extent: self window extent * 0.9.
			^ nil ].
	arg2 title: 'Studio frontend is analyzing data from the backend'.
	^ RJITProcess new fromPath: tmp1 firstOutput ] asJob run
]

{ #category : #'scripting opening' }
StudioInspector >> open [
	| tmp1 |
	tmp1 := self openOn: StudioWelcome new.
	self browser selection: 42.
	^ tmp1
]
