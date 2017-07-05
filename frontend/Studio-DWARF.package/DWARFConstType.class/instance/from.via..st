instance creation
from: dict via: references
   (dict includesKey: 'type')
      ifTrue: [ type := references at: (dict at: 'type') ]
      ifFalse: [ type := DWARFVoid ].