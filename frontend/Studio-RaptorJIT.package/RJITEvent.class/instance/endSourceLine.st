accessing
endSourceLine
	self numberOfBytecodes = 0 ifTrue: [ ^'?' ].
	^ self jitState bytecodes last sourceLine.