tests
randomByteArraySize: size
	| array |
	array := ByteArray ofSize: size.
	1 to: size do: [ :i | array at: i put: 256 atRandom - 1 ].
	^ array.