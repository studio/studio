decoding
decodeGCobjectAt: anAddress
	| gcobj |
	gcobj := self decodeTypeNamed: 'GCobj' at: anAddress.
