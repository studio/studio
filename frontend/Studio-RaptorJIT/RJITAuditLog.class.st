Class {
	#name : #RJITAuditLog,
	#superclass : #Object,
	#instVars : [
		'events',
		'flashback',
		'dwarf',
		'traces',
		'irModes',
		'ctypes',
		'process'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'instance creation' }
RJITAuditLog class >> loadFromFileNamed: fileName withDWARF: dwarf [
	^self new dwarf: dwarf; loadFromFileNamed: fileName.

]

{ #category : #decoding }
RJITAuditLog >> addBlob: dict [
	(dict at: 'name') = 'lj_dwarf.dwo' ifTrue: [ 
		self addDWARF: (dict at: 'data') ].
]

{ #category : #accessing }
RJITAuditLog >> addDWARF: byteArray [
	self dwarf: (DWARF new loadFromByteArray: byteArray)
]

{ #category : #initialization }
RJITAuditLog >> addEvent: dict [
	| event |
	event := self makeEventFrom: dict.
	event number: events size + 1.
	events add: event.
]

{ #category : #initializing }
RJITAuditLog >> addMemory: dict [
   flashback := RJITFlashback new
		auditLog: self;
      previous: flashback;
      address: (dict at: 'address');
      data: (dict at: 'data') asByteArray;
      hint: (dict at: 'hint');
		setup.
	"Detect special memory."
	flashback hint = 'lj_ir_mode' ifTrue: [ irModes := flashback asIrModes ]
	
]

{ #category : #initialization }
RJITAuditLog >> addRecord: dict [
   | type |
   type := dict at: 'type'.
   type = 'event' ifTrue:  [ self addEvent: dict ].
   type = 'memory' ifTrue: [ self addMemory: dict ].
	type = 'blob' ifTrue: [ self addBlob: dict ].
]

{ #category : #visualization }
RJITAuditLog >> ctypeName: id [
	^ self ctypes at: id ifAbsent: [ 'CT#', id asString ]

]

{ #category : #visualization }
RJITAuditLog >> ctypes [
	ctypes ifNil: [ 
		ctypes := Dictionary new.
		events select: [ :e | e class = RJITNewCTypeIDEvent ] thenDo: [ :e |
			ctypes at: e id put: e desc ]
	].
	^ ctypes

]

{ #category : #accessing }
RJITAuditLog >> dwarf [
	^ dwarf
]

{ #category : #initialization }
RJITAuditLog >> dwarf: aDWARF [
   dwarf := aDWARF.
]

{ #category : #initializing }
RJITAuditLog >> events [
	^ events

]

{ #category : #initializing }
RJITAuditLog >> flashbacks [
	^ flashback asOrderedCollection.

]

{ #category : #'as yet unclassified' }
RJITAuditLog >> irModes [
	^irModes
]

{ #category : #'as yet unclassified' }
RJITAuditLog >> irOperandModes [
	self shouldBeImplemented.
]

{ #category : #initialization }
RJITAuditLog >> loadFromFileNamed: fileName [
	| log mp stream count percent |
	[ :job |
		job title: 'Reading audit.log into memory'.
		events := OrderedCollection new.
		"Read into memory."
		log := fileName asFileReference binaryReadStream contents.
		stream := ReadStream on: log.
		mp := MpDecoder on: stream.
		count := 1.
		percent := 0.
		[ [  mp atEnd ] whileFalse: [
			job title: 'Reading audit.log record #', count asString.
			self addRecord: mp next.
			count := count + 1.
			job progress: stream position / log size.
			((stream position * 100.0 / log size) floor / 5) floor > (percent / 5) floor ifTrue: [ 
				percent := (stream position * 100.0 / log size) floor.
				Transcript show: ('Reading audit.log progress: {1}% ({2} events)'
										format: { percent. count. }); cr. ]
			]
		] on: Error do: [ :e | UIManager default inform: 'Finishing at msgpack error: ', e asString ].
	] asJob run.
	UIManager default inform: 'Loaded ', events size asString, ' RaptorJIT events (auditlog)'.
]

{ #category : #initialization }
RJITAuditLog >> makeEventFrom: dict [
   | event |
	event := dict at: 'event'.
   event = 'trace_stop' ifTrue: [ ^RJITTraceStopEvent new from: dict flashback: flashback ].
   event = 'trace_abort' ifTrue: [ ^RJITTraceAbortEvent new from: dict flashback: flashback ].
	event = 'new_prototype' ifTrue: [  ^RJITNewPrototypeEvent new from: dict flashback: flashback ].
	event = 'new_ctypeid' ifTrue: [ ^RJITNewCTypeIDEvent new from: dict flashback: flashback ].
   ^RJITUnknownEvent new from: dict flashback: flashback.

]

{ #category : #accessing }
RJITAuditLog >> process [
	^ process
]

{ #category : #accessing }
RJITAuditLog >> process: aRJITProcess [ 
	process := aRJITProcess
]

{ #category : #visualization }
RJITAuditLog >> traces [
	traces ifNil: [ 
		traces := OrderedCollection new.
		events select: #hasTrace thenDo: [ :e |
			traces add: (e gcTraceWithExistingTraces: traces). ] ].
	^traces.

]
