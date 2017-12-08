accessing
summary
	^ { 'VM' -> interp + c + exit + record + opt + asm.
		 'GC' -> igc + jgc.
		 'Mcode' -> head + loop + ffi. }.