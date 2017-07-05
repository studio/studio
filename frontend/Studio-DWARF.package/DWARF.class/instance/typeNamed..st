accessing
typeNamed: typename
	^types detect: [ :t | t typename = typename ].