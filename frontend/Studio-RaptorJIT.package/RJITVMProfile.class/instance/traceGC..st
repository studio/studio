accessing
traceGC: tr 
	^(traceGC at: tr ifAbsent: 0) / totalSamples.