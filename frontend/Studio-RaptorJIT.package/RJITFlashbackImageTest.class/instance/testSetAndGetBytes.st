tests
testSetAndGetBytes
	1 to: 1000 do: [ :i |
		| array address time readback |
		array := self randomByteArraySize: 10000 atRandom.
		address := 100000 atRandom.
		time := 100 atRandom.
		image setBytes: array atAddress: address atTime: time.
		readback := image getBytes: array size atAddress: address atTime: time.
		self assert: array = readback. ].
