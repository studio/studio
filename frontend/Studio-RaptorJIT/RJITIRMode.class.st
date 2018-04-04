Class {
	#name : #RJITIRMode,
	#superclass : #Object,
	#instVars : [
		'op1mode',
		'op2mode'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #initialization }
RJITIRMode >> from: u8 [
	| operandModes |
	"See lj_ir.h"
	operandModes := { 0 -> #ref. 1 -> #lit. 2 -> #cst. 3 -> #none. } asDictionary.
	op1mode := operandModes at: (u8 bitAnd: 3).
	op2mode := operandModes at: ((u8 bitShift: -2) bitAnd: 3).
	"ignore other mode bits for now."
]

{ #category : #accessing }
RJITIRMode >> op1mode [
	^ op1mode
]

{ #category : #accessing }
RJITIRMode >> op2mode [
	^ op2mode
]
