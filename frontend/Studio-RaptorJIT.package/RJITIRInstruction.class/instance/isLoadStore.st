initialization
isLoadStore
	^ self isLoad or: [ self isStore ].
