initialization
totals
	^ { #c -> c. #gc -> gc. #exit -> exit. #record -> record. #opt -> opt. #asm -> asm.
	    #head -> ((0 to: 4096) sum: [ :tr | traceHead at: tr ifAbsent: 0 ]).
		 #loop -> ((0 to: 4096) sum: [ :tr | traceLoop at: tr ifAbsent: 0 ]). }
