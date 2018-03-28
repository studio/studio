initialization
loadFromFileNamed: fileName
	| log mp stream |
	[ :job |
		job title: 'Reading RaptorJIT audit.log'.
		events := OrderedCollection new.
		log := (File named: fileName) readStream upToEnd.
		stream := ReadStream on: log.
		mp := MpDecoder on: stream.
		[  mp atEnd ] whileFalse: [
			self addRecord: mp next.
			job progress: stream position / log size. ]
	] asJob run.
