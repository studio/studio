accessing
gtInspectorInfoIn: composite
	<gtInspectorPresentationOrder: 1>
	composite fastTable
		title: 'Info';
		display: [ self info ];
		column: 'Name' evaluated: #key width: 100;
		column: 'Value' evaluated: #value width: 600.
