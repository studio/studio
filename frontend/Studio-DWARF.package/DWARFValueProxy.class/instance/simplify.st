accessing
simplify
	^ dwarfValue type isBasic ifTrue: [ dwarfValue value ] ifFalse: [ self ].