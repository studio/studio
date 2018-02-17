accessing
irInstructionAt: anAddress
	^RJITIRInstruction new irIns: (self decodeTypeNamed: #IRIns at: anAddress).