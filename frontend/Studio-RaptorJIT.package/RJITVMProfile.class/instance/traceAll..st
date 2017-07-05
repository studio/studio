accessing
traceAll: tr
	^(self traceHead: tr) + (self traceLoop: tr) + (self traceGC: tr) + (self traceFFI: tr).
