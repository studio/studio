accessing
lineinfo
	| array size |
	lineinfo ifNotNil: [ ^ lineinfo ].
	array := (gcproto child: #lineinfo) asInteger.
	size := (gcproto child: #sizebc) value.
	lineinfo := (0 to: size-1) collect: [ :ix |
		(gcproto flashback decodeTypeNamed: 'uint32_t' at: array + (ix*4)) value ].	
	^ lineinfo