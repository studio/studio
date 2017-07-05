initialization
from: dict via: references
	name := dict at: 'name' ifAbsent: [nil].
	type := references at: (dict at: 'type').
	enumerators :=
		dict values
			select: #isDictionary
			thenCollect: [ :x | (x at: 'name') -> (x at: 'const_value') ].
	enumerators sort: [ :a :b | a value < b value ].