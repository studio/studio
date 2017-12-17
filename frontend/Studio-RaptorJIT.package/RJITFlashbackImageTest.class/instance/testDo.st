tests
testDo
	| block |
	block := [ :page :index | (page at: index) = -1 ].
	image do: block address: 1000000 atRandom bytes: 10000 atRandom time: 100 atRandom.
