gt-inspector-extension
gtInspectorIRListingIn: composite
	| insns |
	<gtInspectorPresentationOrder: 3>
	insns := self irInstructions.
	composite text
		title: 'IR Listing';
		display: (String streamContents: [ :s |
			insns do: [ :i | s nextPutAll: i irString; cr. ] ]).
