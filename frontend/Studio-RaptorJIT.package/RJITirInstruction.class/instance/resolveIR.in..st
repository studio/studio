initialization
resolveIR: num in: aGCtrace
	| bias idx |
	bias := dwarf resolveConstant: 'REF_BIAS'.
	idx := num - bias.
	idx >= 0
		ifTrue: [ ^ aGCtrace irInstructions at: idx ifAbsent: [nil] ]
		ifFalse: [ ^ aGCtrace irConstants at: 0 - idx ifAbsent: [nil] ].
