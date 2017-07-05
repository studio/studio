printing
childOf: dwValue named: name
	^ (self children: dwValue value) asDictionary at: name ifAbsent: [nil].
