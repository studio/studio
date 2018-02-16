accessing
startSourceLine
	| pt line |
	pt := self startPrototype.
	line := pt programCounterLine: jitState cur startpc.
	^ pt sourceName, ':', line asString.