instance creation
command: commandLine
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
