initializing
loop
	^ self irInstructions detect: #isLoop ifNone: [nil].