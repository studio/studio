accessing
irConstants
	irConstants isBlock ifTrue: [ irConstants := irConstants value. ].
	^ irConstants