accessing
includesAddress: anAddress byteSize: size
	^ (anAddress to: anAddress + size) allSatisfy: [ :addr | self includes: addr. ].
