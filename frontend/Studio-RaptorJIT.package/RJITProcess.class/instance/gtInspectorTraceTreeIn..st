accessing
gtInspectorTraceTreeIn: composite
	<gtInspectorPresentationOrder: 5>
	composite fastTable
		title: 'Trace List';
		display: auditLog traces;
		column: 'traceno' evaluated: [ :tr | tr traceno ] width: 60;
		"column: 'start' evaluated: [ :tr | tr start value first ] width: 90;"
		column: 'root' evaluated: [ :tr | tr root ifNotNil: #traceno ifNil: [ '-' ] ] width: 60;
		column: 'parent' evaluated: [ :tr | tr parent ifNotNil: #traceno ifNil: [ '-' ] ] width: 60;
		column: 'link' evaluated: [ :tr | tr link ifNotNil: #traceno ifNil: [ '-' ] ] width: 60;
		column: 'linktype' evaluated: #linktype width: 60;
		column: 'exitno' evaluated: #exitno width: 60;
		column: 'irins' evaluated: [ :tr | tr irInstructions size ] width: 60;
		column: 'loop' evaluated: [ :tr | tr loop ifNotNil: [ 'yes' ] ifNil: [ '-' ] ] width: 60.