Class {
	#name : #RJITTrace,
	#superclass : #Object,
	#instVars : [
		'dwarf',
		'gctrace',
		'irConstants',
		'irInstructions',
		'traceno',
		'root',
		'parent',
		'exitno',
		'link',
		'linktype',
		'start',
		'jitState',
		'nins',
		'mcode',
		'mcodeAddress',
		'mcodeInstructions'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITTrace >> allChildren [
	| set children |
	set := Set new.
	children := self children.
	children do: [ :c | set addAll: c allChildren ].
	set addAll: children.
	^ set.

]

{ #category : #accessing }
RJITTrace >> ancestorFunctionContour [
	parent ifNil: [ ^ '' ] ifNotNil: [ 
		^ parent ancestorFunctionContour ,
			'Parent trace ', parent traceno asString, String cr, 
			parent functionContour, String cr. ]
]

{ #category : #initialization }
RJITTrace >> bytecodes [
	^ jitState bytecodes
]

{ #category : #accessing }
RJITTrace >> children [
	^ self process traces select: [ :tr | tr parent = self ]
]

{ #category : #'instance creation' }
RJITTrace >> decodeIrMcodeMapping [
	| szirmcode mcodeAddr mcodeOffset flashback nbytes index szmcode |
	flashback := gctrace flashback.
	szirmcode := gctrace szirmcode asInteger.
	szmcode := gctrace szmcode asInteger.
	mcodeAddr := gctrace mcode asInteger.
	self mcode: (flashback bytesAt: mcodeAddr size: szmcode) address: mcodeAddr.
	"First value is size of trace head (before first instruction)"
	mcodeOffset := (flashback decodeTypeNamed: #uint16_t at: szirmcode) value.
	index := 2.
	self irInstructions do: [ :ins |
		nbytes := (flashback decodeTypeNamed: #uint16_t at: szirmcode + index) value.
		ins mcode: (flashback bytesAt: mcodeAddr + mcodeOffset size: nbytes).
		ins szmcode: nbytes.
		ins mcodeAddress: mcodeAddr + mcodeOffset.
		index := index + 2. "next uint16_t"
		mcodeOffset := mcodeOffset + nbytes.
	].

]

{ #category : #disassemble }
RJITTrace >> disassembleFrom: startAddr to: endAddr [ 
	| lines |
	lines := self mcodeInstructions select: [ :i | i key >= startAddr and: i key < endAddr ]
										thenCollect: #value.
	^ String cr join: lines.

]

{ #category : #accessing }
RJITTrace >> exitno [
	^ exitno
]

{ #category : #accessing }
RJITTrace >> family [
	^ self process traces select: [ :tr | tr root = root ]

]

{ #category : #accessing }
RJITTrace >> flashback [
	^ gctrace flashback
]

{ #category : #'instance creation' }
RJITTrace >> from: aGCtrace withExistingTraces: traces [
	| flashback bias irAddress nk |
	gctrace := DWARFValueProxy on: aGCtrace.
	flashback := gctrace dwarfValue flashback.
	dwarf := flashback auditLog dwarf.
	bias := dwarf resolveConstant: #REF_BIAS.
	irAddress := gctrace ir value abs.
	nk := bias - gctrace nk value.
	nins := gctrace nins value - bias - 1.
	irConstants := [ (1 to: nk) collect: [ :i |
		[flashback irInstructionAt: irAddress + ((bias - i) * 8) index: i ] on: Error do: [ ] ] ].
	irInstructions := [ (1 to: nins - 1) collect: [ :i |
		flashback irInstructionAt: irAddress + ((bias + i) * 8) index: i ] ].
	traceno := gctrace traceno.
	root := traces detect: [ :tr | tr traceno = gctrace root ] ifNone: [ self ].
	parent := traces detect: [  :tr | tr traceno = gctrace parent ] ifNone: [ nil ].
	exitno := parent isNil ifTrue: [ nil ] ifFalse: [ gctrace exitno ].
	link := traces detect: [ :tr | tr traceno = gctrace link ] ifNone: [ nil ].
	linktype := (dwarf valueToName: gctrace linktype inEnumerationWith: 'LJ_TRLINK_NONE') asLinkTypeName.
	start := gctrace startpc.

]

{ #category : #accessing }
RJITTrace >> functionContour [
	| curdepth |
	^ String streamContents: [ :s |
		jitState bytecodes select: [ :bc | bc opcode isNotNil ] thenDo: [ :bc |
			curdepth ~= bc framedepth ifTrue: [
				curdepth := bc framedepth.
				s
					nextPutAll: ('    ' repeat: bc framedepth + 1);
					nextPutAll: ' ';
					nextPutAll: bc sourceLine;
					nextPut: Character cr.
				 ] ] ].
]

{ #category : #accessing }
RJITTrace >> gtContourFor: aView [
	<gtView>
	^aView textEditor
		title: 'Contour';
		priority: 5;
		look: BrGlamorousCodeEditorLook new;
		text: [ (self printString, String cr, self functionContour) asRopedText ].

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtFamilyFor: aView [
	<gtView>
	^ aView mondrian
		title: 'Family';
		priority: 25;
		painting: [ :view |
			view nodes
			  shape: [ :x |
				| text |
				text := BlTextElement new
			      text: (x startLineShort asRopedText foreground: x hotnessColor).
				x = self ifTrue: [
					text padding: (BlInsets all: 5); border: (BlBorder paint: x hotnessColor width: 2).].
				text ];
			  with: self family.
			view edges
			  fromCenterBottom;
			  toCenterTop;
			  connectFrom: #parent.
			view layout tree levelDistance: 20; nodeDistance: 20.
			view ].
]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtIRListingFor: aView [
	<gtView>
	^ self irInstructionsNoNop irColumnedListViewIn: aView title: 'IR List'.

]

{ #category : #deprecated }
RJITTrace >> gtInspectorBytecodesIn: composite [
	"<gtInspectorPresentationOrder: 2>"
	jitState ifNil: [ ^nil ].
	jitState gtInspectorBytecodesIn: composite.

]

{ #category : #deprecated }
RJITTrace >> gtInspectorContourIn: composite [
	"<gtInspectorPresentationOrder: 2>"
	composite textEditor
		title: 'Contour';
		display: [
			self printString asRopedText italic, String cr, self functionContour ].

]

{ #category : #deprecated }
RJITTrace >> gtInspectorDWARFIn: composite [
	"<gtInspectorPresentationOrder: 6>"
	^ gctrace dwarfValue gtInspectorDWARFIn: composite.
]

{ #category : #deprecated }
RJITTrace >> gtInspectorGCTraceIn: composite [
	"<gtInspectorPresentationOrder: 5>"
"	^ gctrace dwarfValue gtInspectorDWARFIn: composite."
]

{ #category : #deprecated }
RJITTrace >> gtInspectorIRListingIn: composite [
	"<gtInspectorPresentationOrder: 3>"
	self irInstructionsNoNop irListViewIn: composite title: 'IR List'.

]

{ #category : #deprecated }
RJITTrace >> gtInspectorIRTreeIn: composite [
	"<gtInspectorPresentationOrder: 4>"
	composite roassal2
		title: 'IR Tree';
		initializeView: [ self irTreeView ].

]

{ #category : #deprecated }
RJITTrace >> gtInspectorJITIn: composite [
	"<gtInspectorPresentationOrder: 5>"
	composite fastList 
		title: 'JIT';
		display: [ self jitEvents ].

]

{ #category : #deprecated }
RJITTrace >> gtInspectorProfileIn: composite [
	"<gtInspectorPresentationOrder: 6>"
	| tab |
	tab := composite fastTable 
		title: 'Profile';
		display: [ self process vmprofiles collect: [ :p | p trace: self ] ];
		format: #asString;
			sorted: [ :x :y | x all > y all ];
			column: 'Profile' evaluated: [ :pt | pt vmprofile name ].
	#( interp c igc exit record opt asm head loop ffi jgc ) do: [ :key |
		tab column: key asString evaluated: key width: 45 ].


]

{ #category : #deprecated }
RJITTrace >> gtInspectorSummaryIn: composite [
	"<gtInspectorPresentationOrder: 1>"
	composite fastTable
		title: 'Summary';
		display: [ self info ];
		selectionTransformation: #value;
		column: 'Name' evaluated: #key width: 100;
		column: 'Value' evaluated: #value width: 600.

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtJITFor: aView [
	<gtView>
	^aView list
		title: 'JIT Events';
		priority: 25;
		items: [ self jitEvents ].

]

{ #category : #accessing }
RJITTrace >> gtMCodeFor: aView [
	<gtView>
	^aView textEditor
		title: 'MCode';
		priority: 10;
		look: BrGlamorousCodeEditorLook new;
		text: [ (self mcodeDump) asRopedText ].

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtProfileFor: aView [
	<gtView>
	^ self profile gtProfileFor: aView

]

{ #category : #initializing }
RJITTrace >> hasLoop [
	^ self loop notNil.
]

{ #category : #initializing }
RJITTrace >> headInstructions [
	^ self irInstructions copyUpTo: self loop.
]

{ #category : #accessing }
RJITTrace >> hotness [
	^ [ (self process totalSamplesFor: self) / self process totalSamples ] 
		on: ZeroDivide do: [ 0.0 ].
]

{ #category : #accessing }
RJITTrace >> hotnessColor [
	^ Color red mixed: self hotness * 5 with: Color black.

]

{ #category : #accessing }
RJITTrace >> info [
	^{
		'Self' -> self.
		'Parent' -> (parent ifNil: ['-']).
		'Link' -> (link ifNil: [ self linkname ]).
		'Root' -> (root = self ifTrue: [ '(self)' ] ifFalse: [ root = parent ifTrue: [ '(parent)' ] ifFalse: [ root ] ]).
		'---' -> '---'.
		'Parent Exit' -> (parent ifNil: [ '-' ] ifNotNil: [ exitno ]).
		'# Bytecode insns' -> self bytecodes size.
		'# IR insns' -> self numberOfIrInstructions.
		'Profiler samples' -> ('{1} ({2}%)' format: {
			self totalSamples.
			(self totalSamples * 100.0 / (Float fmin + self process totalSamples)) printShowingDecimalPlaces: 1.
		}).
	}
]

{ #category : #accessing }
RJITTrace >> irConstants [
	irConstants isBlock ifTrue: [
		irConstants := irConstants value.
		irConstants select: #notNil thenDo: [ :ins | ins link: self ] ].
	^ irConstants
]

{ #category : #'text dump' }
RJITTrace >> irDump [
	^ self printString, String cr, self irListing.

]

{ #category : #initializing }
RJITTrace >> irInstructions [
	irInstructions isBlock ifTrue: [ 
		irInstructions := irInstructions value.
		irInstructions do: [ :ins | ins link: self. ].
		self decodeIrMcodeMapping.
 		].
	^ irInstructions.

]

{ #category : #accessing }
RJITTrace >> irInstructionsNoNop [
	^ self irInstructions reject: #isNop.
]

{ #category : #'as yet unclassified' }
RJITTrace >> irListing [
	^ String streamContents: [ :s |
		self irInstructionsNoNop do: [ :i | s nextPutAll: i irString; cr. ] ].

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> irTreeView [
	^ self irTreeViewOfInstructions: self irInstructionsNoNop.
]

{ #category : #accessing }
RJITTrace >> isRootTrace [
	^ parent isNil or: [ exitno = 0 and: [ parent isRootTrace ] ].

]

{ #category : #accessing }
RJITTrace >> isSideTrace [
	^ self isRootTrace not.
]

{ #category : #accessing }
RJITTrace >> jitEvents [
	^ gctrace flashback auditLog events select: [ :event |
		event isTraceEvent and: [ 
			event jitState parentTraceno = gctrace parent and: [ 
				event jitState startpc value = gctrace startpc value ] ] ].
]

{ #category : #accessing }
RJITTrace >> jitState: aJitState [
	jitState := aJitState.
]

{ #category : #accessing }
RJITTrace >> link [
	^ link.
]

{ #category : #accessing }
RJITTrace >> linkname [
	^linktype = #root
		ifTrue: [ '->', link traceno asString ]
		ifFalse: linktype.

]

{ #category : #accessing }
RJITTrace >> linktype [
	^ linktype
]

{ #category : #initializing }
RJITTrace >> loop [
	^ self irInstructions detect: #isLoop ifNone: [nil].
]

{ #category : #initializing }
RJITTrace >> loopInstructions [
	^ self irInstructions copyAfter: self loop.
]

{ #category : #'instance creation' }
RJITTrace >> mcode: anArray address: anAddress [
	mcode := anArray.
	mcodeAddress := anAddress.

]

{ #category : #'text dump' }
RJITTrace >> mcodeDump [
	^ self printString, String cr, self mcodeListing.

]

{ #category : #'instance creation' }
RJITTrace >> mcodeInstructions [
	"Answer an ordered collection of address->disasssembly associations.
	The result has one entry per machine instruction, with the address giving the
	address of the instruction and the disassembly being a line of text from
	the disassembler."
	mcodeInstructions ifNil: [
		| disasm |
		disasm := RJITDisassembler disassemble: mcode address: mcodeAddress.
		mcodeInstructions := disasm lines collect: [ :line |
			(Integer readFrom: line base: 16) -> line. ] ].
	^ mcodeInstructions

]

{ #category : #'as yet unclassified' }
RJITTrace >> mcodeListing [
	^ String streamContents: [ :s |
		self irInstructionsNoNop do: [ :i |
			| mcode firstmcode |
			mcode := i disassemble lines.
			firstmcode := mcode ifEmpty: [ '' ] ifNotEmpty: [ mcode first ].
			s
				nextPutAll: (firstmcode padRightTo: 54);
				nextPutAll: ' | ';
				nextPutAll: i irString;
				cr.
			mcode allButFirstDo: [ :nextmcode |
				s
					nextPutAll: (nextmcode padRightTo: 54);
					nextPutAll: ' |';
					cr. ]
			]
		].
]

{ #category : #initializing }
RJITTrace >> numberOfHeadIrInstructions [
	^ self headInstructions size.
]

{ #category : #initializing }
RJITTrace >> numberOfIrInstructions [
	^ nins.
]

{ #category : #accessing }
RJITTrace >> ownFunctionContour [
	^ self printString, String cr, self functionContour.

]

{ #category : #accessing }
RJITTrace >> parent [
	^parent
]

{ #category : #accessing }
RJITTrace >> parentname [
	^ parent ifNil: [ '' ] ifNotNil: [ parent traceno asString , '/' , exitno asString ].
]

{ #category : #printing }
RJITTrace >> printOn: aStream [
	aStream nextPutAll: 'trace '.
	aStream nextPutAll: traceno asString.
	"self isSideTrace ifTrue: [ aStream nextPutAll: ' (' , self parentname, ')' ]."
	aStream nextPutAll: (self hasLoop ifTrue: [ ' loop at ' ] ifFalse: [ ' line from ' ]).
	aStream nextPutAll: self startLineShort.
	self hasLoop ifFalse: [ 
		aStream nextPutAll: ' to '.
		aStream nextPutAll:
			(link
				ifNil: [ self linkname ]
				ifNotNil: [ link bytecodes first sourceLineShort. ]) ]

]

{ #category : #accessing }
RJITTrace >> process [
	^ gctrace flashback auditLog process
]

{ #category : #accessing }
RJITTrace >> profile [
	^ self process traceProfiles detect: [ :profile | profile subject = self ]
]

{ #category : #accessing }
RJITTrace >> root [
	^ root
]

{ #category : #accessing }
RJITTrace >> start [
	^ start
]

{ #category : #accessing }
RJITTrace >> startLine [
	^ self startPrototype sourcePC: self start.

]

{ #category : #accessing }
RJITTrace >> startLineShort [
	^ self startPrototype sourcePCShort: gctrace startpc.

]

{ #category : #accessing }
RJITTrace >> startPrototype [
	^ gctrace flashback decodeGCprotoAt: gctrace startpt.

]

{ #category : #testing }
RJITTrace >> test [
	^ { 
		self gtIRListingFor: GtPhlowView empty.
		self gtJITFor: GtPhlowView empty.
		self gtProfileFor: GtPhlowView empty.
		self irInstructions collect: #test.
	}
]

{ #category : #'text dump' }
RJITTrace >> textDumpInDirectory: dir [ 
	dir ensureCreateDirectory.
	dir dumpStudioFile: 'name.txt' with: [ :s |
		s nextPutAll: self asString withUnixLineEndings ].
	dir dumpStudioFile: 'ir.txt' with: [ :s | 
		s nextPutAll: self irDump withUnixLineEndings ].
	dir dumpStudioFile: 'mcode.txt' with: [ :s | 
		s nextPutAll: self mcodeDump withUnixLineEndings ].
	dir dumpStudioFile: 'contour.txt' with: [ :s | 
		s nextPutAll: self ownFunctionContour withUnixLineEndings ]
	
]

{ #category : #accessing }
RJITTrace >> totalSamples [
	^ self process totalSamplesFor: self.

]

{ #category : #accessing }
RJITTrace >> traceno [
	^ traceno
]

{ #category : #querying }
RJITTrace >> transitiveInputsOf: ins [
	| visit inputs |
	inputs := Set new.
	visit := [ :i | 
		(i isNil or: [ i isConstant or: [ inputs includes: i ] ]) ifFalse: [ 
			inputs add: i.
			visit value: i op1ins; value: i op2ins.
			 ] ].
	visit value: ins.
	^ inputs asArray sort: [ :a :b | a index < b index ].
]

{ #category : #querying }
RJITTrace >> transitiveUsesOf: startIns [
	| uses candidates graph |
	uses := Set new.
	graph := Dictionary new.
	uses add: startIns.
	candidates := self irInstructions.
	candidates do: [ :ins |
		(uses includesAny: { ins op1ins. ins op2ins }) ifTrue: [ 
			uses add: ins ].
	].
	^ uses asArray sort: [ :a :b | a index < b index ]
]

{ #category : #accessing }
RJITTrace >> withAllChildren [
	^ self allChildren add: self; yourself.

]
