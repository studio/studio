accessing
info
	"Answer a collection of associations with key:value information."
	| info |
	info := OrderedCollection new.
	self jitState ifNotNil: [
		self jitState bytecodes size > 0 ifTrue: [ 
			info add: 'start' -> self startSourceLine.
			info add: 'end'   -> self endSourceLine.
		].
		info add: '#bytecodes' -> self numberOfBytecodes.
	 ].
	^ info