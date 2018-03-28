instance creation
build: expr
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
