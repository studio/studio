initialization
totalTraceGC
	^ traceGC inject: 0 into: [ :a :b | a + b ].