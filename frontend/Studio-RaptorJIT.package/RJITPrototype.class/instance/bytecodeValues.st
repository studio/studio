accessing
bytecodeValues
	| array size |
	array := gcproto address + gcproto type byteSize.
	size := (gcproto child: #sizebc) value.
	^ (0 to: size-1) collect: [ :ix |
		(gcproto flashback decodeTypeNamed: #uint32_t at: array + (ix*4)) value ].
