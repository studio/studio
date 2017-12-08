initialization
sourceLine
	^ prototype 
		ifNil: [ '' ]
		ifNotNil: [ prototype sourceName , ':' , (prototype bytecodeLine: position) asString ].
