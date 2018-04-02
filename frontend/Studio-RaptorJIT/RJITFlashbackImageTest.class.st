"
A RJITFlashbackImageTest is a test class for testing the behavior of RJITFlashbackImage
"
Class {
	#name : #RJITFlashbackImageTest,
	#superclass : #TestCase,
	#instVars : [
		'image'
	],
	#category : #'Studio-RaptorJIT-Tests'
}

{ #category : #tests }
RJITFlashbackImageTest >> randomByteArraySize: size [
	| array |
	array := ByteArray ofSize: size.
	1 to: size do: [ :i | array at: i put: 256 atRandom - 1 ].
	^ array.
]

{ #category : #tests }
RJITFlashbackImageTest >> setUp [
	image := RJITFlashbackImage new.
]

{ #category : #tests }
RJITFlashbackImageTest >> testDo [
	| block |
	block := [ :page :index | (page at: index) = -1 ].
	image do: block address: 1000000 atRandom bytes: 10000 atRandom time: 100 atRandom.

]

{ #category : #tests }
RJITFlashbackImageTest >> testEmptyPage [
	self assert: (image emptyPage size = 1024).
]

{ #category : #tests }
RJITFlashbackImageTest >> testGetEmptyPage [
	| page |
	page := image getPage: (1 to: 1000 atRandom) * 1024 atTime: (1 to: 1000) atRandom.
	self assert: (page size = 1024).
	self assert: (page allSatisfy: [ :x | x = -1 ]).
]

{ #category : #tests }
RJITFlashbackImageTest >> testGetPage [
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
]

{ #category : #tests }
RJITFlashbackImageTest >> testSetAndGetBytes [
	1 to: 1000 do: [ :i |
		| array address time readback |
		array := self randomByteArraySize: 10000 atRandom.
		address := 100000 atRandom.
		time := 100 atRandom.
		image setBytes: array atAddress: address atTime: time.
		readback := image getBytes: array size atAddress: address atTime: time.
		self assert: array = readback. ].

]

{ #category : #tests }
RJITFlashbackImageTest >> testSetBytes [
	1 to: 100 do: [ :i |
		image
			setBytes: (self randomByteArraySize: 10000 atRandom)
			atAddress: 1000000 atRandom
			atTime: 100 atRandom ].

]
