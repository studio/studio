accessing
previous: anObject
	previous := anObject.
	previous ifNotNil: [ index := previous index + 1 ].