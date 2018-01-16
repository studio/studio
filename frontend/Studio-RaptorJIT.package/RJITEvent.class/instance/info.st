accessing
info
	"Answer a collection of associations with key:value information."
	| info |
	info := OrderedCollection new.
	self jitState ifNotNil: [
		self jitState bytecodes size > 0 ifTrue: [ 
			info add: 'start' -> self jitState bytecodes first sourceLine.
			info add: 'end'   -> self jitState bytecodes last sourceLine.
		].
		info add: '#bytecodes' -> self jitState bytecodes size.
	 ].
	^ info