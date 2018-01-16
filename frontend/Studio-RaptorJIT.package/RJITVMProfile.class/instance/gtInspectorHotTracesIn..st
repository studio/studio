initialization
gtInspectorHotTracesIn: composite
	<gtInspectorPresentationOrder: 5>
	process ifNil: [ ^nil ].
	^ composite roassal2
		view: (process visualizeTraces: process auditLog traces withProfile: self);
		title: 'Hot Traces'.