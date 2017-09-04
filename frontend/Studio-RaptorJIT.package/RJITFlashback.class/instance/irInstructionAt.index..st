accessing
irInstructionAt: anAddress index: i
	^RJITirInstruction new
		irIns: (self decodeTypeNamed: 'IRIns' at: anAddress);
		index: i;
		yourself.