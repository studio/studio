instance creation
from: dict via: references
   byteSize := dict at: 'byte_size'.
   (dict includesKey: 'type')
      ifTrue: [ type := references at: (dict at: 'type') ]
      ifFalse: [ type := DWARFVoid ].