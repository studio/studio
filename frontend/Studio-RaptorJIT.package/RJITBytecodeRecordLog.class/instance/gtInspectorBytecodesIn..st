accessing
gtInspectorBytecodesIn: composite
	<gtInspectorPresentationOrder: 5>
	composite fastTable
		title: 'Bytecodes';
		display: [ self bytecodes ];
		enableElementIndex;
		column: 'Index' evaluated: [ :x :idx | idx ] width: 60;
		column: 'Depth' evaluated: #framedepth width: 60;
		column: 'Opcode' evaluated: #opcodeName width: 60;
		column: 'Line' evaluated: #sourceLine width: 250.
