tests
testGetPage
	1 to: 100 do: [ :i |
		| array address time wp1 wp2 wp3 wp4 wp5 |
		array := self randomByteArraySize: 10000 atRandom.
		address := 1024 * 1000000 atRandom.
		time := 100 atRandom.
		wp1 := image getPageForWriteAtAddress: address time: time.
		wp2 := image getPageForWriteAtAddress: address time: time.
		self assert: (wp1 == wp2).
		wp3 := image getPageForReadAtAddress: address time: time.
		wp4 := image getPageForReadAtAddress: address time: time + 5.
		self assert: (wp2 == wp3).
		self assert: (wp3 == wp4).
		wp5 := image getPageForWriteAtAddress: address time: time + 3.
		self assert: (wp4 ~~ wp5). ].