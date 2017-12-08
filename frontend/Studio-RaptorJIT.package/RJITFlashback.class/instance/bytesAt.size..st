accessing
bytesAt: anAddress size: size
	| array oldindex newindex |
	array := Array new: size.
	oldindex := 0.
	newindex := 0.
	[
		newindex := self loadBytesAt: anAddress into: array index: oldindex limit: (1<<64).	
		newindex = oldindex
			ifTrue: [ RJITFlashbackDataMissing new address: anAddress + newindex; signal. ]
			ifFalse: [ oldindex := newindex. newindex+1 < size. ]
	] whileTrue.
	^ array asByteArray.
