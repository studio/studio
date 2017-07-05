initialization
loadFromFileNamed: aFilename
	| data base |
	data := (File named: aFilename) readStream upToEnd.
	[ (data unsignedLongAt: 1) = 16r1d50f007 ] assert.
	[ (data unsignedShortAt: 5) = 2 ] assert.
	"XXX replace hard-coding with DWARF accessors. Or use Nix to convert the whole file to JSON?"
	base := 9.
	interp := data unsignedLongLongAt: base.
	c := data unsignedLongLongAt: base + 8.
	gc := data unsignedLongLongAt: base + 16.
	exit := data unsignedLongLongAt: base + 24.
	record := data unsignedLongLongAt: base + 32.
	opt := data unsignedLongLongAt: base + 40.
	asm := data unsignedLongLongAt: base + 48.
	base := 9 + 56.
	traceHead := Dictionary new.
	traceLoop	 := Dictionary new.
	traceGC := Dictionary new.
	traceFFI := Dictionary new.
	0 to: 4096 do: [ :tr | |offset|
		offset := base + (tr * 8 * 4).
		traceHead at: tr put: (data unsignedLongLongAt: offset).
		traceLoop at: tr put: (data unsignedLongLongAt: offset + 8).
		traceGC at: tr put: (data unsignedLongLongAt: offset + 16).
		traceFFI at: tr put: (data unsignedLongLongAt: offset + 24). ].
	totalSamples := interp + c + gc + exit + record + opt + asm.
	{ traceHead. traceLoop. traceGC. traceFFI. } do: [ :dict |
		dict keysAndValuesRemove: [ :key :value | value = 0 ].
		dict valuesDo: [ :v | totalSamples := totalSamples + v ]. ].
