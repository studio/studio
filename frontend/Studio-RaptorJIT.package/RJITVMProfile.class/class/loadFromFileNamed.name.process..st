instance creation
loadFromFileNamed: filename name: aName process: aProcess
	^self new
		loadFromFileNamed: filename;
		name: aName;
		process: aProcess;
		yourself.