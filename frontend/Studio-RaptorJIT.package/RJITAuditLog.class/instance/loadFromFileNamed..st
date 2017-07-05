initialization
loadFromFileNamed: fileName
	| log mp |
	events := OrderedCollection new.
	log := (File named: fileName) readStream upToEnd.
	mp := MpDecoder onBytes: log.
	[  mp atEnd ] whileFalse: [ self addRecord: mp next. ].
