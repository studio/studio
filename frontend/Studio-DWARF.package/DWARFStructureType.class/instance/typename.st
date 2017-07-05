initialization
typename
	^ name isNil ifTrue: [ 'struct' ] ifFalse: [ 'struct ', name. ].