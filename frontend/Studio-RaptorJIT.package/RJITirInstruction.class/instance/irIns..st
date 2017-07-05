initialization
irIns: dwValue
	| v |
	dwarf := dwValue dwarf.
	irIns := dwValue.
	v := DWARFValueProxy on: dwValue.
	opcode := (dwarf valueToName: v o inEnumerationWith: 'IR_NOP') asIRInstructionName.
	type := (dwarf valueToName: ((v t irt) bitAnd: 16r1f) inEnumerationWith: 'IRT_NIL') asIRInstructionType.
	register := v r.
	stackSlot := v s.
	op1 := v op1.
	op2 := v op2.
	op12 := v op12.
