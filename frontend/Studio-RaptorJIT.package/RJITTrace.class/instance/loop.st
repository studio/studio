initializing
loop
	^ irInstructions detect: #isLoop ifNone: [nil].