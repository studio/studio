initializing
from: dict via: references
   name := dict at: 'name' ifAbsent: [nil].
	type := references at: (dict at: 'type').
	location := dict at: 'data_member_location' ifAbsent: [0].
