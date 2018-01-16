printing
childOf: dwValue named: aName
	^ (self children: dwValue value) asDictionary at: aName ifAbsent: [nil].
