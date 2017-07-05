accessing
bytesAt: startAddress size: size
	^((startAddress to: startAddress + size-1) collect:
		[ :i | self byteAt: i ]) asByteArray.
