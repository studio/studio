initialization
from: bcreclog
	| bcval prototypePointer |
	flashback := bcreclog flashback.
	prototypePointer := (bcreclog child: #pt).
	prototypePointer value = 0 ifTrue: [ 
		"Special case: unknown location."
		opcodeName := #<?>.
		^self ].
	prototype := RJITPrototype new from: (bcreclog child: #pt) dereference.
	position := (bcreclog child: #pos) value.
	framedepth := (bcreclog child: #framedepth) value.
	bcval := prototype bytecodeValue: position.
	opcode := bcval bitAnd: 16rFF.
	a := (bcval bitShift: -8) bitAnd: 16rFF.
	b := (bcval bitShift: -16) bitAnd: 16rFF.
	c := (bcval bitShift: -24) bitAnd: 16rFF.
	d := (bcval bitShift: -16) bitAnd: 16rFFFF.
	opcodeName := (flashback auditLog dwarf valueToName: opcode inEnumerationWith: 'BC_LOOP') asBytecodeInstructionType.
