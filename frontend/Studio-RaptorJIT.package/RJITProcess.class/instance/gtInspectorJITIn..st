accessing
gtInspectorJITIn: composite
	<gtInspectorPresentationOrder: 1>
	^ composite roassal2
		view: (auditLog visualizeMondrianWithProfile: (vmprofiles at: 'default'));
		title: 'JIT'.