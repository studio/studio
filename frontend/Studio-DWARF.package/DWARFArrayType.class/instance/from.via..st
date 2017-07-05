instance creation
from: dict via: references
	| spec |
	elementSize := dict at: 'byte_size' ifAbsent: [nil]. "XXX find example where this is present"
	spec := dict detect: [ :x | x isDictionary ].
	numberOfElements := (spec includesKey: 'upper_bound') ifTrue: [ (spec at: 'upper_bound') + 1 ] ifFalse: [nil].
	elementType := references at: (dict at: 'type').