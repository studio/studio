decoding
decodeType: type at: anAddress
	^ type decode: (self bytesAt: anAddress size: type byteSize)
	   address: anAddress flashback: self.