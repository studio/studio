as yet unclassified
programCounterLine: pc
	| position |
	position := pc value - (gcproto address + gcproto byteSize) / 4.
	^ self bytecodeLine: position.
