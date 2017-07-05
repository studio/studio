decoding
decode: byteArray address: baseAddress flashback: flashback
   | address |
   address := baseAddress + location.
   	^ type decode: (byteArray copyFrom: location + 1 to: location + type byteSize)
	   address: address flashback: flashback.