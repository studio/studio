accessing
locations
	| locations groups |
	locations := OrderedCollection new.
	groups := (process auditLog traces) groupedBy: [ :tr | tr root start ].
	groups keysAndValuesDo: [ :loc :trs |
		locations add: (RJITRootTraceSet new location: loc value; traces: trs; profile: self). ].
	^ locations.