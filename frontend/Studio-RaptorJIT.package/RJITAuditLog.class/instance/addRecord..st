initialization
addRecord: dict
   | type |
   type := dict at: 'type'.
   type = 'event' ifTrue:  [ self addEvent: dict ].
   type = 'memory' ifTrue: [ self addMemory: dict ].