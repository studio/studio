accessing
info
	| info |
	info := super info.
	info add: 'Error reason' -> (self traceError , ': ' , self traceErrorReason).
	info add: 'Final?' -> (self jitState isFinal
		ifTrue: [ 'Yes: The starting point of this trace is now blacklisted' ]
		ifFalse: [ 'No: More attempts to trace from this point as allowed' ]).
	^ info.
