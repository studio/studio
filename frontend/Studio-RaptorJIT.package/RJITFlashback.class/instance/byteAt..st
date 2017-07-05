accessing
byteAt: byteAddress
	(byteAddress between: address and: address + data size - 1) ifTrue: [
		^data at: byteAddress - address + 1. ].
	previous ifNotNil: [
		^previous byteAt: byteAddress ].
	SubscriptOutOfBounds signalFor: byteAddress.