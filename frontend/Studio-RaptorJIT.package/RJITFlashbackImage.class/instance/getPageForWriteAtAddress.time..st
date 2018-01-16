as yet unclassified
getPageForWriteAtAddress: pageAddress time: time
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

