as yet unclassified
getPage: pageAddress atTime: time
	pages ifNil: [ pages := Dictionary new. ].
	^ (pages at: pageAddress ifAbsent: [ {} ])
		detect: [ :assoc | assoc key <= time ] ifFound: #value ifNone: [ self emptyPage ].
