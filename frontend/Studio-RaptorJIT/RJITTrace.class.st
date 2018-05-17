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
		'nins'
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

{ #category : #'gt-inspector-extension' }
RJITTrace >> asElement [
	| base |
	base := self hasLoop ifTrue: [ RTEllipse new ] ifFalse: [ RTBox new ].
	base size: [ :tr |
		| area |
		area := tr numberOfHeadIrInstructions * 10.
		self hasLoop ifTrue: [ 2 * (area / Float pi) sqrt ] ifFalse: [ area sqrt ]].
	base borderColor: Color black;
			color: [ :tr | Color red alpha: ((self totalSamples) / (Float fmin + self process totalSamples)) ].
	self isRootTrace ifTrue: [ base borderColor: Color black; borderWidth: 2 ].
	^ base	+ (RTLabel new color: Color black; text: #traceno) elementOn: self.	
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
	| szirmcode mcodeAddr mcodeOffset flashback nbytes index |
	flashback := gctrace flashback.
	szirmcode := gctrace szirmcode asInteger.
	mcodeAddr := gctrace mcode asInteger.
	"First value is size of trace head (before first instruction)"
	mcodeOffset := (flashback decodeTypeNamed: #uint16_t at: szirmcode) value.
	index := 2.
	self irInstructions do: [ :ins |
		nbytes := (flashback decodeTypeNamed: #uint16_t at: szirmcode + index) value.
		Transcript show: 'nbytes: ', nbytes asString; cr.
		ins mcode: (flashback bytesAt: mcodeAddr + mcodeOffset size: nbytes).
		ins szmcode: nbytes.
		ins mcodeAddress: mcodeAddr + mcodeOffset.
		index := index + 2. "next uint16_t"
		mcodeOffset := mcodeOffset + nbytes.
	].

]

{ #category : #accessing }
RJITTrace >> exitno [
	^ exitno
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

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorBytecodesIn: composite [
	<gtInspectorPresentationOrder: 2>
	jitState ifNil: [ ^nil ].
	jitState gtInspectorBytecodesIn: composite.

]

{ #category : #accessing }
RJITTrace >> gtInspectorContourIn: composite [
	<gtInspectorPresentationOrder: 2>
	composite text
		title: 'Contour';
		display: [ self ownFunctionContour ].

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorDWARFIn: composite [
	<gtInspectorPresentationOrder: 6>
	^ gctrace dwarfValue gtInspectorDWARFIn: composite.
]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorGCTraceIn: composite [
	<gtInspectorPresentationOrder: 5>
"	^ gctrace dwarfValue gtInspectorDWARFIn: composite."
]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorIRListingIn: composite [
	<gtInspectorPresentationOrder: 3>
	self irInstructionsNoNop irListViewIn: composite title: 'IR List'.

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorIRTreeIn: composite [
	<gtInspectorPresentationOrder: 4>
	composite roassal2
		title: 'IR Tree';
		initializeView: [ self irTreeView ].

]

{ #category : #'gt-inspector-extension' }
RJITTrace >> gtInspectorJITIn: composite [
	<gtInspectorPresentationOrder: 5>
	composite fastList 
		title: 'JIT';
		display: [ self jitEvents ].

]

{ #category : #accessing }
RJITTrace >> gtInspectorProfileIn: composite [
	<gtInspectorPresentationOrder: 6>
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

{ #category : #accessing }
RJITTrace >> gtInspectorSummaryIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite fastTable
		title: 'Summary';
		display: [ self info ];
		selectionTransformation: #value;
		column: 'Name' evaluated: #key width: 100;
		column: 'Value' evaluated: #value width: 600.

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

{ #category : #'gt-inspector-extension' }
RJITTrace >> irTreeViewOfInstructions: insns [
	| headInsns loopInsns view head loop all separator popup layoutEdges |
	self hasLoop ifTrue: [
		| loopindex |
		loopindex := self loop index.
		headInsns := insns select: [ :i | i index < loopindex ].
		loopInsns := insns select: [ :i | i index > loopindex ].
	] ifFalse: [ 
		headInsns := insns.
		loopInsns := { }.
	 ].
	head := RTGroup new addAll: (headInsns collect: #asElement); yourself.
	loop := RTGroup new addAll: (loopInsns reject: #isPhi thenCollect: #asElement); yourself.
	all := RTGroup new addAll: head; addAll: loop; yourself.
	separator := RTLabel new color: Color black; height: 18; elementOn: #'LOOP:'.
	view := RTView new.
	view addAll: all.

	popup := RTPopup new
		text: #popupSummary;
		alphaPopupBackground: 1.0;
		borderColor: Color black;
		backgroundColor: Color white.
	all @ popup.
	
	view @ RTZoomableBoxView.
	view @ RTDoubleScrollBar.
	RTEdgeBuilder new
		view: view;
		objects: (self irInstructions);
		shape: (RTLine new color: Color black trans; attachPoint: RJITOperand1AttachPoint new; yourself);
		connectFrom: #op1ins;
		shape: (RTLine new color: Color black trans; attachPoint: RJITOperand2AttachPoint new; yourself);
		connectFrom: #op2ins.
	layoutEdges := RTElement edgesForLongTree: all.
	RTTreeLayout new doNotAttachPoint; userDefinedEdges: layoutEdges; on: head.
	RTTreeLayout new doNotAttachPoint; "userDefinedEdges: layoutEdges;" on: loop.
	RTEdgeBuilder new
		view: view;
		objects: (self irInstructions);
		shape: (RTArrowedLine new color: (Color red alpha: 0.5); attachPoint: RTBorderAttachPoint new);
		connectFrom: #phiChild.
	loopInsns size > 0 ifTrue: [
		view add: separator.
		RTVerticalLineLayout on: { head. separator. loop }. ].
	^ view 
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
	^ 'Trace ', self traceno asString, String cr, self functionContour.

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
	aStream nextPutAll: (self hasLoop ifTrue: [ ' loop at ' ] ifFalse: [ ' patch from ' ]).
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

{ #category : #initializing }
RJITTrace >> roassal [
	| view elements head loop headIns loopIns insShape shapeContainer shapeIns headLabel loopLabel line border |
	view := RTView new.
	"Border surrounding the trace."
	border := RTBox new width: 250; color: Color transparent; borderColor: Color black; element.
	"Containers for the head and loop with a separating line."
	shapeContainer := RTBox new width: 200; color: Color transparent; yourself.
	head := shapeContainer element.
	loop := shapeContainer element.
	line := RTBox new extent: 250@1; element.
	"Shapes for the individual instructions."
	shapeIns := (RTBox new size: 20; color: [ :e | e roassalColor ]).
	headIns := (shapeIns elementsOn: self headInstructions).
	loopIns := shapeIns elementsOn: self loopInstructions.
	"Put everything into the view."
	view add: border; add: head; add: loop; addAll: headIns; addAll: loopIns; add: line.
	"Apply layout."
	headIns @ (RTLabeled center text: #opcode).
	RTGridLayout new lineItemsCount: 10; on: headIns; on: loopIns.
	RTVerticalLineLayout new on: { head. line. loop. }.
	RTVerticalLineLayout new on: { border. }.
	"Setup nesting."
	RTNest new
	   on: head nest: headIns; 
	   on: loop nest: loopIns;
	   on: border nest: { head. line. loop. }.
	"Final tweaks."
	border width: 250.
	RTAlignment new elements: { head. loop. }; left.
   ^view
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
