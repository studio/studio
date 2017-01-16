accessing instances and variables
default
	default := default ifNil: [ self new ].
	^default.
