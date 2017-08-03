initialization
from: dict via: references
	name := dict at: 'name'.
	(dict includesKey: 'type') ifTrue: [ 
		type := references at: (dict at: 'type') ].