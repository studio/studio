decoding
decodeJITStateAt: anAddress
	^ RJITJITState new from: (self decodeTypeNamed: #jit_State at: anAddress asInteger).
