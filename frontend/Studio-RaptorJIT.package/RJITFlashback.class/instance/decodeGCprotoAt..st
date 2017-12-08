decoding
decodeGCprotoAt: anAddress
	^ RJITPrototype new from: (self decodeTypeNamed: 'GCproto' at: anAddress asInteger).
