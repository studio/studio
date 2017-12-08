accessing
gtInspectorEventsIn: composite
	<gtInspectorPresentationOrder: 2>
	composite fastList
		title: 'Events';
		display: [ self auditLog events reverse ].
