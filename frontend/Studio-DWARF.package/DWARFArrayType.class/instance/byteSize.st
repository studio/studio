accessing
byteSize
	"XXX not sure if elementSize is correctly decoded."
	^ numberOfElements * (elementSize ifNil: elementType byteSize).