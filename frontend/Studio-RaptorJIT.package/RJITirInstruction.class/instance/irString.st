printing
irString
	"LOOP is a special case"
	opcode = #loop ifTrue: [ ^ self irRefString , ' ------ LOOP ------------' ].
	^ String streamContents: [ :s |
		s
			nextPutAll: self irRefString;
			space;
			nextPutAll: (self isGuardedAssertion ifTrue: '>' ifFalse: ' ');
			nextPutAll: (isPhiOperand ifTrue: '+' ifFalse: ' ');
			space;
			nextPutAll: (self type = #nil ifTrue: [ '   ' ] ifFalse: [ self type ]);
			space;
			nextPutAll: (opcode padRightTo: 6).
		op1ins ifNotNil: [ s space; nextPutAll: (op1ins irRefString padRightTo: 5) ].
		mode op1mode = #lit ifTrue: [ s space; nextPutAll: '#' , op1 printString ].
		op2ins ifNotNil: [ s space; nextPutAll: (op2ins irRefString padRightTo: 5) ].
		mode op2mode = #lit ifTrue: [ s space; nextPutAll: '#' , op2 printString ].
		].
 