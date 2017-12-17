initialization
getPageForReadAtAddress: pageAddress time: time
	"Get the page at a given time for reading.
	Answer the newest page at the timestamp or before.
	Answer an empty page if none is found."
	pages ifNil: [ pages := Dictionary new. ].
	^ (pages at: pageAddress ifAbsent: {})
		detect: [ :assoc | assoc key <= time ]
		ifFound: #value
		ifNone: [ self emptyPage ].
