accessing
jitEvents
	^ gctrace flashback auditLog events select: [ :event |
		event hasTrace and: [ 
			event jitState parentTraceno = gctrace parent and: [ 
				event jitState startpc value = gctrace startpc value ] ] ].