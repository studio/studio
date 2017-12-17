decoding
childOf: dwValue named: aName
	| value |
	value := super childOf: dwValue named: aName.
	^ value ifNotNil: [ value value ].