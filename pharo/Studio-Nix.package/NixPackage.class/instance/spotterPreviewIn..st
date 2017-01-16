accessing
spotterPreviewIn: aComposite
	<spotterPreview: 10>
	^ aComposite table 
		title: 'Nix Package';
		display: [ | meta |
			meta := table at: 'meta'.
			{ 'attribute path' -> attrpath.
			  'name' -> (table at: 'name').
			  'description' -> (meta at: 'description' ifAbsent: ['(none)']).
			  'homepage' -> (meta at: 'homepage' ifAbsent: ['(none)']).
			  'longDescription' -> (meta at: 'longDescription' ifAbsent: ['(none)']).
			 } ];
		column: 'Field' evaluated: #key;
		column: 'Value' evaluated: #value;
		entity: self