initialization
totalTraceLoop
	^ traceLoop inject: 0 into: [ :a :b | a + b ].