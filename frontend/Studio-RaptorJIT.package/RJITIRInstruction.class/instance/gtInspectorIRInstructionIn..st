initialization
gtInspectorIRInstructionIn: composite
	<gtInspectorPresentationOrder: 1>
	composite table
		display: [ self attributes ];
		column: 'Key' evaluated: #key width: 100;
		column: 'Value' evaluated: #value.
