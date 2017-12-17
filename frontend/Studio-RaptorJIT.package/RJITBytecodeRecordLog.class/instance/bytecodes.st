accessing
bytecodes
	^ bytecodes select: [ :bc | bc opcode isNotNil ].