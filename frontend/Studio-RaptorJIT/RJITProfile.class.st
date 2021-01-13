"
I represent the ""profile"" of a subject: the distribution of virtual machine states observed by the sampling profiler.

The subject can be anything e.g. a whole process, a trace, a set of traces, etc.

I provide convenient methods for computing useful metrics like ratios between states.
"
Class {
	#name : #RJITProfile,
	#superclass : #Object,
	#instVars : [
		'subject',
		'interp',
		'c',
		'igc',
		'exit',
		'record',
		'opt',
		'asm',
		'head',
		'loop',
		'jgc',
		'ffi',
		'id',
		'vmprofile'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'instance creation' }
RJITProfile class >> empty [
	| new |
	new := self new.
	#(interp: c: igc: exit: record: opt: asm: head: loop: jgc: ffi:) do: [ :selector |
		new perform: selector with: 0 ].
	^ new

]

{ #category : #'instance creation' }
RJITProfile class >> of: aSubject aggregating: aCollection [ 
	| profile |
	profile := self empty subject: aSubject.
	aCollection do: [ :otherProfile | profile add: otherProfile ].
	^ profile

]

{ #category : #updating }
RJITProfile >> add: aProfile [
	"XXX Find a better repr than instance variables."
	interp := interp + aProfile interp.
	c := c + aProfile c.
	igc := igc + aProfile igc.
	exit := exit + aProfile exit.
	record := record + aProfile record.
	opt := opt + aProfile opt.
	asm := asm + aProfile asm.
	head := head + aProfile head.
	loop := loop + aProfile loop.
	jgc := jgc + aProfile jgc.
	ffi := ffi + aProfile ffi.
]

{ #category : #'derived samples' }
RJITProfile >> all [
	^ self native + self vm + self gc.

]

{ #category : #'raw samples' }
RJITProfile >> asm [
	^ asm
]

{ #category : #'raw samples' }
RJITProfile >> asm: anObject [
	asm := anObject
]

{ #category : #'raw samples' }
RJITProfile >> c [
	^ c
]

{ #category : #'raw samples' }
RJITProfile >> c: anObject [
	c := anObject
]

{ #category : #'raw samples' }
RJITProfile >> exit [
	^ exit
]

{ #category : #'raw samples' }
RJITProfile >> exit: anObject [
	exit := anObject
]

{ #category : #'raw samples' }
RJITProfile >> ffi [
	^ ffi
]

{ #category : #'raw samples' }
RJITProfile >> ffi: anObject [
	ffi := anObject
]

{ #category : #metrics }
RJITProfile >> garbageCollection [
	"Answer the percentage of time spent collecting garbage."
	^ self percentOf: self gc.
]

{ #category : #'derived samples' }
RJITProfile >> gc [
	"Answer the number of samples in garbage collection (JIT or interpreter)."
	^ igc + jgc.

]

{ #category : #'inspector extensions' }
RJITProfile >> gtProfileFor: aView [
	<gtView>
	| aList states |
	states := {('Native Trace Code (Loop)' -> self loop).
	('Native Trace Code (Straight)' -> self head).
	('GC for Native Code' -> self jgc).
	('FFI calls' -> self ffi).
	('C Library' -> self c).
	('Bytecode Interpreter' -> self interp).
	('GC for Interpreted Code' -> self igc).
	('Trace Exit Handlers' -> self exit).
	('JIT recording' -> self record).
	('JIT optimization' -> self opt).
	('JIT assembling' -> self asm)}.
	aList := aView columnedList
		title: 'Profile' translated;
		priority: 10;
		items: [ states ].
	aList column
		title: 'State' translated;
		weight: 1;
		item: [ :item :index | item key translated ].
	aList column
		title: 'Percent' translated;
		weight: 1;
		item: [ :item :index | 
			(item value * 100.0 / (self all max: 1) printShowingDecimalPlaces: 1)
				, '%' ].
	aList column
		title: 'Samples' translated;
		weight: 1;
		item: [ :item :index | item value ].
	^ aList
]

{ #category : #'raw samples' }
RJITProfile >> head [
	^ head
]

{ #category : #'raw samples' }
RJITProfile >> head: anObject [
	head := anObject
]

{ #category : #'raw samples' }
RJITProfile >> igc [
	^ igc
]

{ #category : #'raw samples' }
RJITProfile >> igc: anObject [
	igc := anObject
]

{ #category : #'raw samples' }
RJITProfile >> interp [
	^ interp
]

{ #category : #'raw samples' }
RJITProfile >> interp: anObject [
	interp := anObject 
]

{ #category : #'raw samples' }
RJITProfile >> jgc [
	^ jgc
]

{ #category : #'raw samples' }
RJITProfile >> jgc: anObject [
	jgc := anObject
]

{ #category : #'raw samples' }
RJITProfile >> loop [
	^ loop
]

{ #category : #'raw samples' }
RJITProfile >> loop: anObject [
	loop := anObject
]

{ #category : #'derived samples' }
RJITProfile >> native [
	"Answer the number of samples in native code (JIT or FFI)."
	^ head + loop + ffi.

]

{ #category : #metrics }
RJITProfile >> nativeCode [
	^ self percentOf: self native.
]

{ #category : #'raw samples' }
RJITProfile >> opt [
	^ opt
]

{ #category : #'raw samples' }
RJITProfile >> opt: anObject [
	opt := anObject
]

{ #category : #private }
RJITProfile >> percentOf: samples [
	"Answer the percentage that 'samples' reprsents of all samples."
	^ [ samples * 100.0 / self all ] on: ZeroDivide do: [ 0 ].
]

{ #category : #printing }
RJITProfile >> printOn: aStream [
	subject ifNil: [ 'Profile' ] ifNotNil: [ 
		aStream nextPutAll: 'Profile of '.
		subject printOn: aStream. ].
	
]

{ #category : #'raw samples' }
RJITProfile >> record [
	^ record
]

{ #category : #'raw samples' }
RJITProfile >> record: anObject [
	record := anObject
]

{ #category : #accessing }
RJITProfile >> subject [
	^ subject

]

{ #category : #accessing }
RJITProfile >> subject: anObject [
	subject := anObject
	

]

{ #category : #metrics }
RJITProfile >> summary [
	^ { 'VM' -> interp + c + exit + record + opt + asm.
		 'GC' -> igc + jgc.
		 'Mcode' -> head + loop + ffi. }.
]

{ #category : #metrics }
RJITProfile >> virtualMachine [
	^ self percentOf: self vm.
]

{ #category : #'derived samples' }
RJITProfile >> vm [
	"Answer the number of samples interpreting and compiling bytecodes."
	^ interp + c + exit + record + opt + asm.

]

{ #category : #metrics }
RJITProfile >> vmPercent [
	^ self percentOf: self vm.
]
