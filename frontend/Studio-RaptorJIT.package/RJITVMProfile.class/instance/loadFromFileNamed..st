initialization
loadFromFileNamed: aFilename
	| data index |
	data := (File named: aFilename) readStream upToEnd.
	[ (data unsignedLongAt: 1) = 16r1d50f007 ] assert.
	[ (data unsignedShortAt: 5) = 4 ] assert.
	index := 8.
	traces := (0 to: 4096) collect: [ :tr | | trace |
		trace := RJITVMProfileTrace new id: tr.
		#(interp: c: igc: exit: record: opt: asm: head: loop: jgc: ffi:) do: [ :selector |
			trace perform: selector with: (data unsignedLongLongAt: index+1).
			index := index + 8. ].
		trace. ].
