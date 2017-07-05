initialization
isLoad
	^ #(aload hload uload fload xload sload vload) includes: opcode.
