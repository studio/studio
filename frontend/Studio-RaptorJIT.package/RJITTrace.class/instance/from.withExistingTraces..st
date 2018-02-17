instance creation
from: aGCtrace withExistingTraces: traces
	| flashback bias irAddress nk |
	gctrace := DWARFValueProxy on: aGCtrace.
	flashback := gctrace dwarfValue flashback.
	dwarf := flashback auditLog dwarf.
	bias := dwarf resolveConstant: #REF_BIAS.
	irAddress := gctrace ir value abs.
	nk := bias - gctrace nk value.
	nins := gctrace nins value - bias - 1.
	irConstants := [ (1 to: nk) collect: [ :i |
		[flashback irInstructionAt: irAddress + ((bias - i) * 8) index: i ] on: Error do: [ ] ] ].
	irInstructions := [ (1 to: nins - 1) collect: [ :i |
		flashback irInstructionAt: irAddress + ((bias + i) * 8) index: i ] ].
	traceno := gctrace traceno.
	root := traces detect: [ :tr | tr traceno = gctrace root ] ifNone: [ self ].
	parent := traces detect: [  :tr | tr traceno = gctrace parent ] ifNone: [ nil ].
	exitno := parent isNil ifTrue: [ nil ] ifFalse: [ gctrace exitno ].
	link := traces detect: [ :tr | tr traceno = gctrace link ] ifNone: [ nil ].
	linktype := (dwarf valueToName: gctrace linktype inEnumerationWith: 'LJ_TRLINK_NONE') asLinkTypeName.
	start := gctrace startpc.