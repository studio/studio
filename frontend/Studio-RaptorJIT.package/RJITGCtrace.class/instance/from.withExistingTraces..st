instance creation
from: aGCtrace withExistingTraces: traces
	| flashback bias irAddress |
	gctrace := DWARFValueProxy on: aGCtrace.
	flashback := gctrace dwarfValue flashback.
	dwarf := flashback auditLog dwarf.
	bias := dwarf resolveConstant: 'REF_BIAS'.
	irAddress := gctrace ir value abs.
	irConstants := (1 to: bias - gctrace nk value) collect: [ :x | x ].
	irInstructions := (1 to: gctrace nins value - bias - 1) collect: [ :i |
		flashback irInstructionAt: irAddress + ((i + bias) * 8). ].
	irInstructions do: [ :ins | ins link: self. ].
	traceno := gctrace traceno.
	root := traces detect: [ :tr | tr traceno = gctrace root ] ifNone: [nil].
	parent := traces detect: [  :tr | tr traceno = gctrace parent ] ifNone: [ nil ].
	exitno := parent isNil ifTrue: [ nil ] ifFalse: [ gctrace exitno ].
	link := traces detect: [ :tr | tr traceno = gctrace link ] ifNone: [ nil ].
	linktype := (dwarf valueToName: gctrace linktype inEnumerationWith: 'LJ_TRLINK_NONE') asLinkTypeName.
	start := gctrace startpc.