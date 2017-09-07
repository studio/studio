initialization
printOn: aStream
	super printOn: aStream.
   aStream nextPutAll: ' (', opcode, ' <', type, '>)'.