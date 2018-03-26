accessing
gtInspectorDWARFIn: composite
	<gtInspectorPresentationOrder: 1>
	^ composite fastTreeTable
		title: 'DWARF';
		display: [ { '(root)' -> self. } ];
		column: 'Name' evaluated: [ :x | x key ];
		column: 'Value' evaluated: [ :x | x value ];
		column: 'Type' evaluated: [ :x | x value type typename ];
		column: 'Address' evaluated: [ :x | '0x', (x value address printStringBase: 16). ];
		hasChildren: [ :x | x value hasChildren ];
		children: [ :x | x value children ];
		icon: [ :x | x value type icon ];
		expandedUntil: 1.