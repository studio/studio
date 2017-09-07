initialization
popupSummary
	^ (RJITIRInstruction opcodeSummaries at: opcode ifAbsent: [ '(unknown opcode)' ]) ,
		Character cr asString,
		self irString.