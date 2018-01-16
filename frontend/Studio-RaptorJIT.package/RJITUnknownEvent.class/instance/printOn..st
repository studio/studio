printing
printOn: aStream
	aStream
		nextPutAll: '<event: ';
		nextPutAll: (dict at: #event);
		nextPutAll: '>'.