initializing
resolveConstant: name
	types select: #isEnumeration
			thenDo: [ :e | (e nameToValue: name) ifNotNil: [ :value | ^value ]. ].
	^nil.
