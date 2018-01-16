accessing
byteAt: byteAddress
	^ (self bytesAt: byteAddress size: 1) first.
