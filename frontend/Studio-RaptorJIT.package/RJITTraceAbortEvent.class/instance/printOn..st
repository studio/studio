printing
printOn: aStream
	| final |
	final := self jitState isFinal ifTrue: '(final) ' ifFalse: ''.
	aStream nextPutAll: 'trace abort ', final, ' from ', self startSourceLine, ' to ', self endSourceLine, ' (', self numberOfBytecodes asString, ' bytecodes)'