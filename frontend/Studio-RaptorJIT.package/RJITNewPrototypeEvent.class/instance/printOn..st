printing
printOn: aStream
	aStream
		nextPutAll: '<new_prototype: ';
		nextPutAll: self asGCproto sourceName;
		nextPutAll: '>'.