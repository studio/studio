decoding
decodeArrayOfTypeNamed: typename at: anAddress elements: elems
	| type |
	type := (auditLog dwarf typeNamed: typename).
	^ (0 to: elems - 1) collect: [ :ix |
		| elementAddress |
		elementAddress := anAddress asInteger + (ix * type byteSize).
		self decodeType: type at: elementAddress ].
