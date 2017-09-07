roassal
shape
	| shape |
"
	true ifTrue: [ 
		^(RTBox new width: 50; height: 20; borderColor: Color lightGray; color: self roassalColor) +
			(RTLabel new text: opcode asString).
 ].
"
	shape := RTCompositeShape new.
	(op1ins notNil and: [op1ins isConstant]) ifTrue: [
		shape add: ((RTBox new width: 50; height: 20; borderColor: Color lightGray; color: Color transparent) +
			(RTLabel new color: Color veryDarkGray; text: op1ins irRefString)) allOfSameSize ].
	shape add:
		(RTBox new width: 50; height: 20; borderColor: Color lightGray; color: self roassalColor) +
		(RTLabel new color: Color veryDarkGray; text: opcode asString).
	(op2ins notNil and: [op2ins isConstant]) ifTrue: [
		shape add: ((RTBox new width: 50; height: 20; borderColor: Color lightGray; color: Color transparent) +
				(RTLabel new color: Color veryDarkGray; text: op2ins irRefString)) allOfSameSize ].
	shape horizontal.
	^shape