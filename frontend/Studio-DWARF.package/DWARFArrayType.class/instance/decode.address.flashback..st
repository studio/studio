instance creation
decode: byteArray address: address flashback: flashback
   | elements |
	elements := (0 to: numberOfElements - 1) collect: [ :i | | eachSize offset bytes |
		eachSize := elementSize ifNil: elementType byteSize.
		offset := eachSize * i.
		bytes := byteArray copyFrom: offset + 1 to: offset + elementType byteSize.
		elementType decode: bytes address: address flashback: flashback. ].
	^ DWARFValue type: self value: elements address: address flashback: flashback.