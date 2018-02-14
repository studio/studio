printing
printOn: aStream
	aStream nextPutAll: 'trace stop (success) from ', self startSourceLine, ' to ', self endSourceLine, ' (', self numberOfBytecodes asString, ' bytecodes)'