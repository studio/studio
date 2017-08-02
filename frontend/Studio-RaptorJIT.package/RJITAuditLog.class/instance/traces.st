visualization
traces
	traces ifNil: [ 
		traces := OrderedCollection new.
		events select: #hasTrace thenDo: [ :e |
			traces add: (e gcTraceWithExistingTraces: traces). ] ].
	^traces.
