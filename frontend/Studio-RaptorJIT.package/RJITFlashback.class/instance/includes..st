accessing
includes: byteAddress
	[ self byteAt: byteAddress ] on: SubscriptOutOfBounds do: [ ^ false ].
	^ true.
