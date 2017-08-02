instance creation
realize: deriv
	| process outputs |
	process := PipeableOSProcess command: 'nix-store --realize ', deriv.
	process close.
	outputs := process outputAndError collect: [ :m | TextConverter default convertFromSystemString: m ].
	process succeeded ifFalse: [ NixError new messageText: (outputs at: 2); signal ].
	^(outputs at: 1) lines.
