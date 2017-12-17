tests
testGetEmptyPage
	| page |
	page := image getPage: (1 to: 1000 atRandom) * 1024 atTime: (1 to: 1000) atRandom.
	self assert: (page size = 1024).
	self assert: (page allSatisfy: [ :x | x = -1 ]).