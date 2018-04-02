Class {
	#name : #RJITVMProfileTrace,
	#superclass : #Object,
	#instVars : [
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
		'id'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #accessing }
RJITVMProfileTrace >> all [
	^ self mcode + self vm + self gc.

]

{ #category : #accessing }
RJITVMProfileTrace >> asm [
	^ asm
]

{ #category : #accessing }
RJITVMProfileTrace >> asm: anObject [
	asm := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> c [
	^ c
]

{ #category : #accessing }
RJITVMProfileTrace >> c: anObject [
	c := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> exit [
	^ exit
]

{ #category : #accessing }
RJITVMProfileTrace >> exit: anObject [
	exit := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> ffi [
	^ ffi
]

{ #category : #accessing }
RJITVMProfileTrace >> ffi: anObject [
	ffi := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> gc [
	^ igc + jgc.

]

{ #category : #accessing }
RJITVMProfileTrace >> gcPercent [
	^ self gc * 100.0 / self all.

]

{ #category : #accessing }
RJITVMProfileTrace >> head [
	^ head
]

{ #category : #accessing }
RJITVMProfileTrace >> head: anObject [
	head := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> id [
	^ id
]

{ #category : #accessing }
RJITVMProfileTrace >> id: anInteger [ 
	id := anInteger.
]

{ #category : #accessing }
RJITVMProfileTrace >> igc [
	^ igc
]

{ #category : #accessing }
RJITVMProfileTrace >> igc: anObject [
	igc := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> interp [
	^ interp
]

{ #category : #'as yet unclassified' }
RJITVMProfileTrace >> interp: anInteger [ 
	interp := anInteger
]

{ #category : #accessing }
RJITVMProfileTrace >> jgc [
	^ jgc
]

{ #category : #accessing }
RJITVMProfileTrace >> jgc: anObject [
	jgc := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> loop [
	^ loop
]

{ #category : #accessing }
RJITVMProfileTrace >> loop: anObject [
	loop := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> mcode [
	^ head + loop + ffi.

]

{ #category : #accessing }
RJITVMProfileTrace >> mcodePercent [
	^ self mcode * 100.0 / self all.

]

{ #category : #accessing }
RJITVMProfileTrace >> opt [
	^ opt
]

{ #category : #accessing }
RJITVMProfileTrace >> opt: anObject [
	opt := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> record [
	^ record
]

{ #category : #accessing }
RJITVMProfileTrace >> record: anObject [
	record := anObject
]

{ #category : #accessing }
RJITVMProfileTrace >> summary [
	^ { 'VM' -> interp + c + exit + record + opt + asm.
		 'GC' -> igc + jgc.
		 'Mcode' -> head + loop + ffi. }.
]

{ #category : #accessing }
RJITVMProfileTrace >> vm [
	^ interp + c + exit + record + opt + asm.

]

{ #category : #accessing }
RJITVMProfileTrace >> vmPercent [
	^ self vm * 100.0 / self all.

]
