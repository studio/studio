accessing
sourceName
	^ sourceName trimLeft: [ :x | x = $@ or: x = $= ]