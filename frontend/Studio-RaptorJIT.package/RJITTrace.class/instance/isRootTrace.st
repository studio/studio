accessing
isRootTrace
	^ parent isNil or: [ exitno = 0 and: [ parent isRootTrace ] ].
