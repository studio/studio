Class {
	#name : #RJITAuditLog,
	#superclass : #Object,
	#instVars : [
		'events',
		'flashback',
		'dwarf',
		'traces',
		'irModes'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'instance creation' }
RJITAuditLog class >> loadFromFileNamed: fileName withDWARF: dwarf [
	^self new dwarf: dwarf; loadFromFileNamed: fileName.

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
	| log mp stream count |
	[ :job |
		job title: 'Reading audit.log into memory'.
		events := OrderedCollection new.
		"Read into memory."
		log := fileName asFileReference binaryReadStream contentsOfEntireFile.
		stream := ReadStream on: log.
		mp := MpDecoder on: stream.
		count := 1.
		[  mp atEnd ] whileFalse: [
			job title: 'Reading audit.log record #', count asString.
			self addRecord: mp next.
			count := count + 1.
			job progress: stream position / log size. ]
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
   ^RJITUnknownEvent new from: dict flashback: flashback.

]

{ #category : #visualization }
RJITAuditLog >> traces [
	traces ifNil: [ 
		traces := OrderedCollection new.
		events select: #hasTrace thenDo: [ :e |
			traces add: (e gcTraceWithExistingTraces: traces). ] ].
	^traces.

]

{ #category : #visualization }
RJITAuditLog >> visualize [
	| view traces es |
	view := RTView new.
	traces := self traces.
	es := (RTLabel new text: [ :e | 'Trace ', e traceno asString ]) +
			(RTBox new size: 10; color: Color transparent; borderColor: Color black)
				elementsOn: traces.
	view addAll: es.
	RTNest new
		for: es
		add: [ :group :model |
			group addAll: (RTBox new color: #roassalColor; elementsOn: model irInstructions).
			RTGridLayout on: group ].
	RTEdgeBuilder new
		view: view;
		objects: traces;
		shape:
			(RTLine new
				attachPoint: RTShorterDistanceAttachPoint new;
				color: Color veryDarkGray)
				+
					(RTSimpleArrowHead new
						attachPoint: RTShorterDistanceAttachPoint new;
						color: Color veryDarkGray);
		connectFrom: #root to: #yourself.
	RTHorizontalTreeLayout on: es.
	view @ RTZoomableBoxView.
	^view.
]

{ #category : #visualization }
RJITAuditLog >> visualizeMondrian [
	| b m |
	b := RTMondrian new.
	b shape rectangle withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
	b
		nodes: self traces
		forEach: [ :tr |
			b nodes: (tr hasLoop
							ifTrue:  [ { tr headInstructions. tr loopInstructions select: [ :ins | (#(nop) includes: ins opcode) not ]. } ]
							ifFalse: [ { tr headInstructions. } ])
			forEach: [ :insns |
				b shape rectangle
					color: #roassalColor;
					withText: #opcode height: 1.
				b nodes: insns.
				"b shape arrowedBezier width: 0.1."
				b shape verticalBezierLine width: 0.1; color: (Color black alpha: 0.25).
				b edges connectFrom: #op1ins.
				b edges connectFrom: #op2ins.
				b layout dominanceTree verticalGap: 3 ]. ].
	b edges connectFrom: #parent.
	b layout force.
	m := b build.
	m view @ RTZoomableBoxView.
	^ m
]

{ #category : #visualization }
RJITAuditLog >> visualizeMondrianOverview [
	| b groups |
	groups := self traces groupedBy: [ :x | x root ifNil: [ Object new ] ].
	b := RTMondrian new.
	b shape rectangle
		borderColor: Color black;
		color: Color transparent.
	b nodes: groups
		forEach: [ :group |
		b shape rectangle
			color: Color lightBlue;
			borderColor: Color black;
			size: [ :x | x numberOfIrInstructions sqrt * 10];
			withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
		b nodes: group value.
		b layout dominanceTree.
		b edges connectFrom: #parent. ].
	groups size >= 3 ifTrue: [ b layout packed ] ifFalse: [ b layout force ].
	^ b build.

]

{ #category : #visualization }
RJITAuditLog >> visualizeMondrianWithProfile: aVMProfile [ 
	| b m traces |
	b := RTMondrian new.
	b shape
		rectangle
		borderColor: Color black;
"		color: [ :tr | Color red alpha: (aVMProfile traceAll: tr traceno). ];"
		withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
	traces := self traces select: [ :tr | (aVMProfile traceAll: tr traceno) > 0.05 ].
	b
		nodes: traces
		forEach: [ :tr | |head loop|
			head := tr headInstructions select: [ :ins | (#(nop) includes: ins opcode) not ].
			loop := tr loopInstructions select: [ :ins | (#(nop) includes: ins opcode) not ].
			b shape rectangle
				borderColor: Color black;
				color: [ :insns |
				insns = head
							ifTrue:  [ Color red alphaMixed: (aVMProfile traceHead: tr traceno) with: Color white. ]
							ifFalse: [ Color red alphaMixed: (aVMProfile traceLoop: tr traceno) with: Color white. ]. ].
				b
				nodes: (tr hasLoop ifTrue: { head. loop. } ifFalse: { head. })
				forEach: [ :insns |
					b shape rectangle
						color: #roassalColor;
						borderColor: [ :ins | ins stackSlot = 0 ifTrue: [ Color transparent. ] ifFalse: [ Color black. ] ];
						width: 50;
						height: 20;
						withText: #opcode height: 12 color: Color veryDarkGray.
					b nodes: insns.
					"b shape arrowedBezier width: 0.1."
					b shape
						line
						color: (Color black alpha: 0.33);
						withOperand1AttachPoint.
					b edges connectFrom: #op1ins.
					b shape
						line
						color: (Color black alpha: 0.33);
						withOperand2AttachPoint.
					b edges connectFrom: #op2ins.
					b layout dominanceTree doNotAttachPoint verticalGap: 15 ]. ].
	b edges connectFrom: #root.
	b layout horizontalTree.
	m := b build.
	m view @ RTZoomableBoxView.
	^ m

]
