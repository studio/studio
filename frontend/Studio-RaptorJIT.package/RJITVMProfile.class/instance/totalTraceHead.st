initialization
totalTraceHead
	^ traceHead inject: 0 into: [ :a :b | a + b ].