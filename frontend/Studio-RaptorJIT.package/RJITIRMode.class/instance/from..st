initialization
from: u8
	| operandModes |
	"See lj_ir.h"
	operandModes := { 0 -> #ref. 1 -> #lit. 2 -> #cst. 3 -> #none. } asDictionary.
	op1mode := operandModes at: (u8 bitAnd: 3).
	op2mode := operandModes at: ((u8 bitShift: -2) bitAnd: 3).
	"ignore other mode bits for now."