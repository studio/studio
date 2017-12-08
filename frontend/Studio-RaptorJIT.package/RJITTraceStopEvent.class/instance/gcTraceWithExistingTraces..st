as yet unclassified
gcTraceWithExistingTraces: traces
	trace := RJITTrace new from: self decode withExistingTraces: traces; jitState: jitState.
	^ trace.