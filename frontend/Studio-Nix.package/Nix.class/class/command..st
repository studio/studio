instance creation
command: commandLine
	| process outputs |
	process := PipeableOSProcess command: 'NIX_PATH=studio=', self studioNixPath, ' ', commandLine.
	process close.
	outputs := process outputAndError collect: [ :m | TextConverter default convertFromSystemString: m ].
	process succeeded ifFalse: [ NixError new messageText: (outputs at: 2); signal ].
	^(outputs at: 1).
