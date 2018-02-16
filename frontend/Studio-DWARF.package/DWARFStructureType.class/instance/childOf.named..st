decoding
childOf: dwValue named: aName
	| value |
	value := super childOf: dwValue named: aName. "block -> value"
	^ value.
	"^ value ifNotNil: [ value value ]."
	