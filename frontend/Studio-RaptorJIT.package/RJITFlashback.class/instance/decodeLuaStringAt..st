decoding
decodeLuaStringAt: anAddress
	| gcstr |
	gcstr := self decodeTypeNamed: #GCstr at: anAddress asInteger.
	^ self decodeStringAt: (gcstr address + gcstr type byteSize) size: (gcstr child: #len) value.