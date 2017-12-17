accessing
location
	| root |
	root := traces detect: #isRootTrace ifNone: [ ^'?' ].
	^ root startLine.
