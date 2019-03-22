Class {
	#name : #RJITVMProfile,
	#superclass : #Object,
	#instVars : [
		'interp',
		'c',
		'gc',
		'exit',
		'record',
		'opt',
		'asm',
		'traceHead',
		'traceLoop',
		'traceGC',
		'traceFFI',
		'totalSamples',
		'name',
		'process',
		'igc',
		'head',
		'loop',
		'jgc',
		'ffi',
		'traceInterp',
		'traceProfiles',
		'profile'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'instance creation' }
RJITVMProfile class >> loadFromFileNamed: filename name: aName process: aProcess [
	^self new
		process: aProcess;
		name: aName;
		loadFromFileNamed: filename;
		yourself.
]

{ #category : #'accessing-data' }
RJITVMProfile >> gc [
	^ (traceProfiles collect: #gc) sum.

]

{ #category : #'accessing-statistics' }
RJITVMProfile >> gcPercent [
	^ self gc * 100.0 / self total.
]

{ #category : #initialization }
RJITVMProfile >> gtHotTracesFor: aView [
	<gtView>
	| profiles |
	profiles := self traceProfiles sort: [ :a :b | a all > b all ].
	^ (profiles subjectViewTitled: 'Hot traces' translated subjectName: 'Trace' translated onView: aView).
]

{ #category : #initialization }
RJITVMProfile >> gtInspectorHotTracesIn: composite [
	"<gtInspectorPresentationOrder: 5>"
	process ifNil: [ ^nil ].
	^ composite roassal2
		view: (process visualizeTraces: process auditLog traces withProfile: self);
		title: 'Hot Traces'.
]

{ #category : #initialization }
RJITVMProfile >> loadFromFileNamed: aFilename [
	| data index |
	data := (File named: aFilename) readStream upToEnd.
	[ (data unsignedLongAt: 1) = 16r1d50f007 ]  assert.
	[ (data unsignedShortAt: 5) = 4 ]  assert.
	index := 8.
	traceProfiles := RJITProfileList withAll: ((0 to: process traces size) collect: [ :tr |
		| prof subject |
		subject := { #trace -> tr. #vmprofile -> self. } asDictionary.
		prof := RJITProfile new subject: (self lookupTrace: tr); yourself.
		#(interp: c: igc: exit: record: opt: asm: head: loop: jgc: ffi:) do: [ :selector |
			prof perform: selector with: (data unsignedLongLongAt: index+1).
			index := index + 8. ].
		prof. ])
]

{ #category : #accessing }
RJITVMProfile >> locations [
	| locations groups |
	locations := OrderedCollection new.
	groups := (process auditLog traces) groupedBy: [ :tr | tr root start ].
	groups keysAndValuesDo: [ :loc :trs |
		locations add: (RJITRootTraceSet new location: loc value; traces: trs; profile: self). ].
	^ locations.
]

{ #category : #initialization }
RJITVMProfile >> lookupTrace: traceno [
	^ traceno = 0
		ifTrue: [ '(Unknown)' ]
		ifFalse: [ [ process trace: traceno ]
						on: SubscriptOutOfBounds do: [ '(No trace ', traceno printString, ')'  ] ]
]

{ #category : #'accessing-data' }
RJITVMProfile >> mcode [
	^ (traceProfiles collect: #mcode) sum.

]

{ #category : #'accessing-statistics' }
RJITVMProfile >> mcodePercent [
	^ self mcode * 100.0 / self total.
]

{ #category : #initialization }
RJITVMProfile >> name [
	^name
]

{ #category : #initialization }
RJITVMProfile >> name: aName [
	name := aName.
]

{ #category : #printing }
RJITVMProfile >> printOn: aStream [
	aStream nextPutAll: name
]

{ #category : #initialization }
RJITVMProfile >> process [
	^process
]

{ #category : #initialization }
RJITVMProfile >> process: aRaptorJITProcess [
	process := aRaptorJITProcess.
]

{ #category : #'accessing-data' }
RJITVMProfile >> profile [
	profile ifNil: [ profile := RJITProfile of: self aggregating: self traceProfiles ].
	^ profile

]

{ #category : #testing }
RJITVMProfile >> test [ 
	^ self gtHotTracesFor: GtPhlowView empty.
]

{ #category : #dumping }
RJITVMProfile >> textDumpInDirectory: dir [
	| tracelist sep |
	sep := ' | '.
	tracelist := self traceProfiles select: [ :tr | tr all > 0 ].
	tracelist sort: [ :a :b | a all > b all ].
	dir asFileReference dumpStudioFile: (self name, '.txt') with: [ :s |
		 #(Samples Native VM GC) do: [ :col |
			  s nextPutAll: (col padRightTo: 8), sep. ].
		 s nextPutAll: 'Trace'.
		 s lf.
		 tracelist do: [ :tr |
			  s nextPutAll: (tr all asString padLeftTo: 8), sep.
			  {  tr nativeCode. tr virtualMachine. tr garbageCollection } do: [ :pct |
				   s nextPutAll: ((pct printShowingDecimalPlaces: 1), '%' padLeftTo: 6), '  ', sep ].
			  s nextPutAll: tr subject printString.
			  s lf.
		  ]
	].
        

]

{ #category : #'accessing-data' }
RJITVMProfile >> total [
	^ (traceProfiles collect: #all) sum.

]

{ #category : #'accessing-data' }
RJITVMProfile >> trace: tr [
	^ traceProfiles detect: [ :profile | profile subject = tr ]
]

{ #category : #'accessing-data' }
RJITVMProfile >> traceProfiles [
	^ traceProfiles
]

{ #category : #'accessing-data' }
RJITVMProfile >> traces [
	^ traces
]

{ #category : #'accessing-data' }
RJITVMProfile >> vm [
	^ (traceProfiles collect: #vm) sum.

]

{ #category : #'accessing-statistics' }
RJITVMProfile >> vmPercent [
	^ self vm * 100.0 / self total.
]
