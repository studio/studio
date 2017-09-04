accessing
link: aGCtrace
	mode op1mode = #ref ifTrue: [ op1ins := self resolveIR: op1 in: aGCtrace ].
	mode op2mode = #ref ifTrue: [ op2ins := self resolveIR: op2 in: aGCtrace ].
	opcode = 'phi' ifTrue: [ 
		op1ins ifNotNil: #setPhiOperand.
		op2ins ifNotNil: #setPhiOperand. ]