instance creation
typename
	^ name isNil ifTrue: [ 'union' ] ifFalse: [ 'union ', name. ].