accessing
bytesAt: anAddress size: size
	^ image getBytes: size atAddress: anAddress atTime: time.
