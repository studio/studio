accessing
irInstructionAt: anAddress index: i
	^RJITIRInstruction new
		irIns: (self decodeTypeNamed: 'IRIns' at: anAddress);
		index: i;
		yourself.