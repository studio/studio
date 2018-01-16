initialization
bytecodes
	| raw |
	bytecodes ifNotNil: [ ^bytecodes ].
	raw := self flashback
						decodeArrayOfTypeNamed: 'BCRecLog'
						at: jitState bclog
						elements: jitState nbclog.
	bytecodes := raw collect: [ :bc | RJITBytecode new from: bc ].
	^bytecodes.