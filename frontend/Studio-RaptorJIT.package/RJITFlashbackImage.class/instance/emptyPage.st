as yet unclassified
emptyPage
	| array |
	array := ShortIntegerArray ofSize: 1024.
	(1 to: array size) do: [ :i | array at: i put: -1 ].
	^ array