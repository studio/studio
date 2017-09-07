printing
irRefString
	self isConstant ifFalse: [ 
		^ index printStringLength: 4 padded: true.
	].
	"Constants"
	(opcode = #kpri and: type = #true)  ifTrue: [ ^ 'T' ].
	(opcode = #kpri and: type = #false) ifTrue: [ ^ 'F' ].
	(opcode = #kpri and: type = #nil)   ifTrue: [ ^ 'NULL' ].
	opcode = #kint ifTrue: [ ^ (op12 sign = -1 ifTrue: ['-'] ifFalse: ['+']) , op12 printString ].
	"XXX NYI"
	^ '<' , type , '>'