Class {
	#name : #Nix,
	#superclass : #Object,
	#category : #'Studio-Nix'
}

{ #category : #'instance creation' }
Nix class >> build: expr [
	| derivations |
	[ :job |
		job title: 'Instantiating expression to find derivations'.
		derivations := self instantiate: expr
	] asJob run.
	^ derivations collect: [ :deriv |
		[ :job |
			job title: 'Building derivation: ', deriv.
			(self realize: deriv) last.
		] asJob run ].

]

{ #category : #'instance creation' }
Nix class >> command: commandLine [
	| process stdout stderr out err |
	stdout := WriteStream on: String new.
	stderr := WriteStream on: String new.
	process := PipeableOSProcess command: 'NIX_PATH=studio=', self studioNixPath, ' ', commandLine.
	process close.
	[  process isComplete ] whileFalse: [ 
		process updateErrorPipelineStream.
		out := process upToEnd.
		err := process errorUpToEnd.
		stdout nextPutAll: out.
		stderr nextPutAll: err.
		self showProgress: out.
		self showProgress: err.
		World doOneCycle.
		(Delay forMilliseconds: 50) wait.
	].
	out := process upToEndOfFile.
	err := process errorUpToEndOfFile.
	stdout nextPutAll: out.
	stderr nextPutAll: err.
	self showProgress: out.
	self showProgress: err.
	process succeeded ifFalse: [ NixError new messageText: stderr contents asByteArray utf8Decoded; signal ].
	^ stdout contents.

]

{ #category : #'as yet unclassified' }
Nix class >> eval: expression [
	| tmp process outputs |
	tmp := FileReference newTempFilePrefix: 'eval-' suffix: '.nix'.
	tmp writeStream nextPutAll: expression; cr; close.
	process := PipeableOSProcess command: 'nix-instantiate --eval --strict --xml ', tmp pathString.
	outputs := process outputAndError collect: [ :m | TextConverter default convertFromSystemString: m ].
	process succeeded ifFalse: [ NixError new messageText: (outputs at: 2); signal ].
	tmp delete.
	^XMLDOMParser parse: (outputs at: 1).
]

{ #category : #'instance creation' }
Nix class >> instantiate: expression [
	| tmp |
	tmp := FileReference newTempFilePrefix: 'eval-' suffix: '.nix'.
	tmp writeStream nextPutAll: expression; cr; close.
	[ ^ (self command: 'nix-instantiate ', tmp pathString) lines ]
		ensure: [ tmp delete ].
]

{ #category : #'instance creation' }
Nix class >> realize: deriv [
	^(self command: 'nix-store --realize ', deriv) lines.
]

{ #category : #private }
Nix class >> showProgress: aString [ 
	aString asByteArray utf8Decoded withSqueakLineEndings linesDo: [ :line |
		Transcript show: line; cr.
		({ 'building path(s) *'. 'error: build of *'. 'fetching path *'} anySatisfy: [ :pattern |
			pattern match: line ]) ifTrue: [ 
				"Abbreviate nix store paths"
				UIManager default inform: (line copyWithRegex: '/nix/store/[^-]+-' matchesReplacedWith: '').
			 ]. ].

]

{ #category : #'as yet unclassified' }
Nix class >> studioNixPath [
	"XXX The user needs to know about this somehow..."
	^ OSProcess thisOSProcess environment
		at: #STUDIO_PATH
		ifAbsent: OSProcess thisOSProcess getCwd.
]
