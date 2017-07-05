decoding
decode: aByteArray address: address flashback: flashback
	^ DWARFValue type: self value: (aByteArray perform: accessingSelector with: 1)
	   address: address flashback: flashback.