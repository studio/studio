initialization
resolveIR: num in: aGCtrace
	| bias |
	bias := dwarf resolveConstant: 'REF_BIAS'.
	^ aGCtrace irInstructions at: (num - bias) ifAbsent: [nil].
