tests
testSetBytes
	1 to: 100 do: [ :i |
		image
			setBytes: (self randomByteArraySize: 10000 atRandom)
			atAddress: 1000000 atRandom
			atTime: 100 atRandom ].
