instance creation
from: dict via: references
	name := dict at: 'name' ifAbsent: [nil].
	byteSize := dict at: 'byte_size' ifAbsent: [nil].
	members := dict values select: #isDictionary 
	                       thenCollect: [ :x | DWARFMember new from: x via: references ].
