Class {
	#name : #RJITProcess,
	#superclass : #Object,
	#instVars : [
		'dwarf',
		'auditLog',
		'vmprofiles',
		'path'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITProcess >> auditLog [
	^ auditLog
]

{ #category : #accessing }
RJITProcess >> auditLog: aRJITAuditLog [ 
	auditLog := aRJITAuditLog
]

{ #category : #accessing }
RJITProcess >> dwarf [
	^ dwarf
]

{ #category : #accessing }
RJITProcess >> dwarf: aDWARF [ 
	dwarf := aDWARF
]

{ #category : #'instance creation' }
RJITProcess >> fromPath: aPath [
	| dwarfPath auditPath |
	path := aPath.
	dwarfPath := path / 'raptorjit-dwarf.json'.
	auditPath := path / 'audit.log'.
	[ dwarfPath isFile and: auditPath isFile ] assertWithDescription:
		'JIT audit log not found'.
	auditLog := RJITAuditLog loadFromFileNamed: auditPath pathString withDWARF: (DWARF loadFromFileNamed: dwarfPath pathString).
	"Load VMProfile data with progress monitoring."
	vmprofiles := OrderedCollection new.
	(path / 'vmprofile') children
		do: [ :vmprofile |
			vmprofiles add: (RJITVMProfile loadFromFileNamed: vmprofile pathString name: vmprofile basenameWithoutExtension process: self) ]
		displayingProgress: [ :x | 'Loading VMProfile: ', x base ].
	UIManager default inform: 'Loaded ', vmprofiles size asString, ' RaptorJIT profiles'.
]

{ #category : #accessing }
RJITProcess >> gtInspectorEventsIn: composite [
	<gtInspectorPresentationOrder: 2>
	composite fastList
		title: 'Events';
		display: [ self auditLog events reverse ];
		format: [ :e |
			"Catch errors."
			[ e printString ] on: Error do: [ :err | '<Decoding error: ', err printString, '>' ] ].

]

{ #category : #accessing }
RJITProcess >> gtInspectorFilesIn: composite [
	<gtInspectorPresentationOrder: 9>
	path gtInspectorItemsIn: composite.

]

{ #category : #'instance creation' }
RJITProcess >> gtInspectorVMProfilesIn: composite [
	<gtInspectorPresentationOrder: 1>
	| w percent |
	w := 50. "width of numeric columns"
	^ composite tabulator
		title: 'VM Profile';
		with: [ :t |
			t row: #profiles; row: #locations; row: #traces.
			t transmit to: #profiles; andShow: [ :a |
				percent := [ :sel |
					[ :obj |
						[ ((obj perform: sel) round: 1) asString , '%' ] on: ZeroDivide do: [ '-' ] ] ].
				a fastTable
					title: 'Profiler datasets (VMProfile)';
					display: #vmprofiles;
					column: 'Profile' evaluated: #name width: 100;
					column: 'Samples' evaluated: #total width: 60;
					column: 'Mcode' evaluated: (percent value: #mcodePercent) width: w;
					column: 'VM' evaluated: (percent value: #vmPercent) width: w;
					column: 'GC' evaluated: (percent value: #gcPercent) width: w.	].
			t transmit from: #profiles; to: #locations; andShow: [ :a |
				a fastTable
					title: 'Source code locations of root traces that are hot in the selected profile';
					display: [ :profile | profile locations select: [ :x | x samples > 0 ] ];
					sorted: [ :x :y | x samples > y samples ];
					column: 'Location' evaluated: #location width: 240;
					column: 'Samples' evaluated: #samples width: 60;
					column: '#Root' evaluated: #numberOfRootTraces width: w;
					column: '#Side' evaluated: #numberOfSideTraces width: w. ].
			t transmit from: #locations; to: #traces; andShow: [ :a |
				a fastTreeTable
					title: 'Root traces starting at selected location (and their side-traces as children)';
					display: #profiledTraces;
					children: #children;
					sorted: [ :x :y | x samples > y samples ];
					column: 'Trace' evaluated: #traceno width: 160;
					column: 'Samples' evaluated: #samples width: 60;
					column: 'Link' evaluated: #linktype width: 60;
					column: 'Mcode' evaluated: (percent value: #mcodePercent) width: w;
					column: 'VM' evaluated: (percent value: #vmPercent) width: w;
					column: 'GC' evaluated: (percent value: #gcPercent) width: w;
					column: 'Start line' evaluated: #location width: 240;
					column: 'Stop line' evaluated: [ :x | '-' ] width: 240;
					allExpanded. ].
			t transmit toOutsidePort: #selection; from: #traces port: #selection transformed: #trace.
			].

]

{ #category : #visualization }
RJITProcess >> visualizeTraces: traces withProfile: profile [
	| b groups |
	b := RTMondrian new.
	b shape rectangle
		borderColor: Color black;
		color: Color transparent.
	groups := (traces groupedBy: [ :x | x root ifNil: [ Object new ] ]).
	profile ifNotNil: [ 
		groups := groups select: [ :group | | samples |
			samples := group inject: 0 into: [ :acc :tr | acc + (profile traceAll: tr traceno) ].
			samples > 0 ifTrue: [Transcript show: samples; show: ' '; show: profile totalSamples; cr. ].
			samples > 0.1  ]
		].
	b nodes: groups
		forEach: [ :group |
		b shape rectangle
			color: [ :tr | Color red alphaMixed: (profile traceAll: tr traceno) with: Color white ];
			borderColor: Color black;
			size: 100;
			withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
		b nodes: group value.
		b layout dominanceTree.
		b edges connectFrom: #parent. ].
	b layout flow.
	^ b build.

]

{ #category : #accessing }
RJITProcess >> vmProfile: aVMProfile named: name [ 
	vmprofiles ifNil: [ vmprofiles := Dictionary new. ].
	vmprofiles at: name put: aVMProfile.

]

{ #category : #accessing }
RJITProcess >> vmprofiles [
	^ vmprofiles
]
