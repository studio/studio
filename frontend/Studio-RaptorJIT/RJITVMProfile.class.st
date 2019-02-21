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
		loadFromFileNamed: filename;
		name: aName;
		process: aProcess;
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
	[ (data unsignedLongAt: 1) = 16r1d50f007 ] assert.
	[ (data unsignedShortAt: 5) = 4 ] assert.
	index := 8.
	traceProfiles := (0 to: 4096) collect: [ :tr |
		| profile subject |
		subject := { #trace -> tr. #vmprofile -> self. } asDictionary.
		profile := RJITProfile new subject: subject; yourself.
		#(interp: c: igc: exit: record: opt: asm: head: loop: jgc: ffi:) do: [ :selector |
			profile perform: selector with: (data unsignedLongLongAt: index+1).
			index := index + 8. ].
		profile. ].

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

{ #category : #'accessing-data' }
RJITVMProfile >> total [
	^ (traceProfiles collect: #all) sum.

]

{ #category : #'accessing-data' }
RJITVMProfile >> trace: tr [
	^ traceProfiles detect: [ :profile | profile subject at: #trace = (tr traceno) ]
]

{ #category : #'accessing-data' }
RJITVMProfile >> traceProfiles [
	^ traceProfiles
]

{ #category : #'accessing-data' }
RJITVMProfile >> vm [
	^ (traceProfiles collect: #vm) sum.

]

{ #category : #'accessing-statistics' }
RJITVMProfile >> vmPercent [
	^ self vm * 100.0 / self total.
]
