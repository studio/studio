decoding
sizeOfTypeNamed: typename
	^ (auditLog dwarf typeNamed: typename) byteSize.