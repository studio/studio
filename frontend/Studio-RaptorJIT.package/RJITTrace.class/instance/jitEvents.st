accessing
jitEvents
	^ gctrace flashback auditLog events select: [ :event |
		event hasTrace and: [ 
			| trace |
			trace := event trace.
			"check startpc"
			"check parent" ] ]