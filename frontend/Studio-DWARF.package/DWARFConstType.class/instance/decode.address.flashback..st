decoding
decode: byteArray address: address flashback: flashback 
	^DWARFValue type: self value: (type decode: byteArray address: address flashback: flashback) value
	   address: address flashback: flashback.
	