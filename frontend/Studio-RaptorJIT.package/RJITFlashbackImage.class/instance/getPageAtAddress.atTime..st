as yet unclassified
getPageAtAddress: pageAddress atTime: time
	(pages at: pageAddress ifAbsent: [ {} ])
		detect: [ :assoc | assoc key <= time ] ifFound: #value ifNone: [ self emptyPage ].
