initialization
gtInspectorHotTracesIn: composite
	<gtInspectorPresentationOrder: 5>
	^ composite roassal2
		view: (process visualizeTraces: process auditLog traces withProfile: self);
		title: 'Hot Traces'.