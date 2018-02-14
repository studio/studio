accessing
startSourceLine
	self numberOfBytecodes = 0 ifTrue: [ ^'?' ].
	^ self jitState bytecodes first sourceLine.