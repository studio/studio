initialization
accessingSelectorForEncoding: enc byteSize: size
   (enc matchesRegex: '.*\(unsigned.*') ifTrue: [ 
	   size = 1 ifTrue: [ ^#unsignedByteAt: ].
	   size = 2 ifTrue: [ ^#unsignedShortAt: ].
	   size = 4 ifTrue: [ ^#unsignedLongAt: ].
	   size = 8 ifTrue: [ ^#unsignedLongLongAt: ]. ].
   (enc matchesRegex: '.*\(signed.*') ifTrue: [ 
	   size = 1 ifTrue: [ ^#signedByteAt: ].
	   size = 2 ifTrue: [ ^#signedShortAt: ].
	   size = 4 ifTrue: [ ^#signedLongAt: ].
	   size = 8 ifTrue: [ ^#signedLongLongAt: ]. ].
   (enc matchesRegex: '.*\(float\)') ifTrue: [ 
	   size = 4 ifTrue: [ ^#floatAt: ].
      size = 8 ifTrue: [ ^#doubleAt: ] ].
