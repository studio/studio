accessing
irInstructionAt: anAddress
	^RJITirInstruction new irIns: (self decodeTypeNamed: 'IRIns' at: anAddress).