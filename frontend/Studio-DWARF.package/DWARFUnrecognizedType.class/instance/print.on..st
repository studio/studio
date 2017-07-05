printing
print: none on: aStream
	[ none isNil ] assert.
	aStream nextPutAll: '<?>'.