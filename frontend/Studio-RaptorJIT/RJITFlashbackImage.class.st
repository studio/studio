Class {
	#name : #RJITFlashbackImage,
	#superclass : #Object,
	#instVars : [
		'pages'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #initialization }
RJITFlashbackImage >> do: aBlock address: address bytes: size time: time [
	| firstPageAddress |
	firstPageAddress := address bitClear: 1023.
	(firstPageAddress to: address + size by: 1024) do: [ :pageAddress |
		| page firstOffset lastOffset |
		page := self getPage: pageAddress atTime: time.
		"Interval within the page to fill."
		firstOffset := address - pageAddress max: 0.
		lastOffset := address + size - 1 - pageAddress min: 1023.
		(firstOffset to: lastOffset) do: [ :offset |
			aBlock value: page value: offset+1. ] ].

]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> do: aBlock address: address bytes: size time: time create: create [
	| firstPageAddress |
	firstPageAddress := address bitClear: 1023.
	(firstPageAddress to: address + size by: 1024) do: [ :pageAddress |
		| page firstOffset lastOffset |
		page := create ifTrue:  [ self getPageForWriteAtAddress: pageAddress time: time ]
							  ifFalse: [  self getPageForReadAtAddress: pageAddress time: time ].
		"Interval within the page to fill."
		firstOffset := address - pageAddress max: 0.
		lastOffset := address + size - 1 - pageAddress min: 1023.
		(firstOffset to: lastOffset) do: [ :offset |
			aBlock value: page value: offset+1. ] ].

]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> do: aBlock address: address bytes: size time: time readOnly: readOnly [
	| firstPageAddress |
	firstPageAddress := address bitClear: 1023.
	(firstPageAddress to: address + size by: 1024) do: [ :pageAddress |
		| page firstOffset lastOffset |
		page := readOnly ifTrue:  [ self getPage: pageAddress atOrBeforeTime: time ]
							  ifFalse: [  self getPage: pageAddress atTime: time ].
		"Interval within the page to fill."
		firstOffset := address - pageAddress max: 0.
		lastOffset := address + size - 1 - pageAddress min: 1023.
		(firstOffset to: lastOffset) do: [ :offset |
			aBlock value: page value: offset+1. ] ].

]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> emptyPage [
	| array |
	array := ShortIntegerArray ofSize: 1024.
	(1 to: array size) do: [ :i | array at: i put: -1 ].
	^ array
]

{ #category : #initialization }
RJITFlashbackImage >> getBytes: size atAddress: address atTime: time [
	| array stream block |
	array := ByteArray ofSize: size.
	stream := array writeStream.
	block := [ :page :i |
		| byte |
		byte := page at: i.
		byte = -1 ifTrue: [ RJITFlashbackDataMissing new signal ].
		stream nextPut: byte ].
	self do: block address: address bytes: size time: time create: false.
	stream close.
	^ array.
]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> getPage: pageAddress atTime: time [
	pages ifNil: [ pages := Dictionary new. ].
	^ (pages at: pageAddress ifAbsent: [ {} ])
		detect: [ :assoc | assoc key <= time ] ifFound: #value ifNone: [ self emptyPage ].

]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> getPageAtAddress: pageAddress atTime: time [
	(pages at: pageAddress ifAbsent: [ {} ])
		detect: [ :assoc | assoc key <= time ] ifFound: #value ifNone: [ self emptyPage ].

]

{ #category : #initialization }
RJITFlashbackImage >> getPageForReadAtAddress: pageAddress time: time [
	"Get the page at a given time for reading.
	Answer the newest page at the timestamp or before.
	Answer an empty page if none is found."
	pages ifNil: [ pages := Dictionary new. ].
	^ (pages at: pageAddress ifAbsent: {})
		detect: [ :assoc | assoc key <= time ]
		ifFound: #value
		ifNone: [ self emptyPage ].

]

{ #category : #'as yet unclassified' }
RJITFlashbackImage >> getPageForWriteAtAddress: pageAddress time: time [
	pages ifNil: [ pages := Dictionary new. ].
	^ (pages at: pageAddress ifAbsentPut: [ self newPageList. ])
					detect: [ :assoc | assoc key = time ]
					ifFound: [ :assoc | assoc value ]
					ifNone: [
						| basePage newPage |
						"Create a page at the exact right timestamp.
						Initialize contents from the most recent readable page."
						basePage := self getPageForReadAtAddress: pageAddress time: time.
						newPage := basePage copy.
						(pages at: pageAddress) add: time -> newPage.
						newPage. ].


]

{ #category : #private }
RJITFlashbackImage >> newPageList [
	^ SortedCollection sortBlock: [ :a :b | a key > b key ].
]

{ #category : #initialization }
RJITFlashbackImage >> setBytes: array atAddress: address atTime: time [
	| stream block |
	stream := array readStream.
	block := [ :page :i | page at: i put: stream next ].
	self do: block address: address bytes: array size time: time create: true.

]

{ #category : #initialization }
RJITFlashbackImage >> setPage: page atAddress: address atTime: time [
	(pages at: address ifAbsentPut: [ Heap sortBlock: [ :a :b | a key < b key ]])
		add: time -> page.

]
