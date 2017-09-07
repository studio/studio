initialization
isConstant
	^ #(kpri kint kgc kptr kkptr knull knum kint64 kslot) includes: opcode.
