initialization
sourceLine
	prototype ifNil: [ ^ '' ].
	^ [ prototype sourceName , ':' , (prototype bytecodeLine: position) asString ]
		ifCurtailed: [ ^'?' ].
