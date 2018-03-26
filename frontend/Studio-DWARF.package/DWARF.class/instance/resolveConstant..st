initializing
resolveConstant: name
	alltypes select: #isEnumeration
			thenDo: [ :e | (e nameToValue: name) ifNotNil: [ :value | ^value ]. ].
	^nil.
