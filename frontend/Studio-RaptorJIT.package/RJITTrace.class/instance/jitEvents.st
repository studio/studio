accessing
jitEvents
	^ gctrace flashback auditLog events select: [ :event |
		event isTraceEvent and: [ 
			event jitState parentTraceno = gctrace parent and: [ 
				event jitState startpc value = gctrace startpc value ] ] ].