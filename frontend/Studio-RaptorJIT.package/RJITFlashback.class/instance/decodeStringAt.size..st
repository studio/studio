accessing
decodeStringAt: anAddress size: size
	^ (self bytesAt: anAddress size: size) asString
