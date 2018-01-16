initializing
irInstructions
	irInstructions isBlock ifTrue: [ 
		irInstructions := irInstructions value.
		irInstructions do: [ :ins | ins link: self. ].
 		].
	^ irInstructions.
