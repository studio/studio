Class {
	#name : #RJITIRInstruction,
	#superclass : #Object,
	#instVars : [
		'type',
		'opcode',
		'irIns',
		'register',
		'stackSlot',
		'op1',
		'op2',
		'op12',
		'op1ins',
		'op2ins',
		'dwarf',
		'index',
		'isPhiOperand',
		'mode',
		'trace'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'as yet unclassified' }
RJITIRInstruction class >> opcodeSummaries [
	^ {
  #lt -> 'LT (left, right): left < right (signed)'.
  #ge -> 'GE (left, right): left >= right (signed)'.
  #le -> 'LE (left, right): left <= right (signed)'.
  #gt -> 'GT (left, right): left > right (signed)'.
  #ult -> 'ULT (left, right): left < right (unsigned/unordered)'.
  #uge -> 'UGE (left, right): left >= right (unsigned/unordered)'.
  #ule -> 'ULE (left, right): left <= right (unsigned/unordered)'.
  #ugt -> 'UGT (left, right): left > right (unsigned/unordered)'.
  #eq -> 'EQ (left, right): left = right'.
  #ne -> 'NE (left, right): left ~= right'.
  #abc -> 'ABC (bound, index): Array Bounds Check: bound > index (unsigned)'.
  #retf -> 'RETF (proto, pc): Return to lower frame: check target PC, shift base'.
  #bnot -> 'BNOT (ref): Bitwise NOT of ref'.
  #bswap -> 'BSWAP (ref): Byte-swapped ref'.
  #band -> 'BAND (left, right): Bitwise AND of left and right'.
  #bor -> 'BOR (left, right): Bitwise OR of left and right'.
  #bxor -> 'BXOR (left, right): Bitwise XOR of left and right'.
  #bshl -> 'BSHL (ref, shift): Bitwise left shift of ref'.
  #bshr -> 'BSHR (ref, shift): Bitwise logical right shift of ref'.
  #bsar -> 'BSAR (ref, shift): Bitwise arithmetic right shift of ref'.
  #brol -> 'BROL (ref, shift): Bitwise left rotate of ref'.
  #bror -> 'BROR (ref, shift): Bitwise right rotate of ref'.
  #add -> 'ADD (left, right): left + right'.
  #sub -> 'SUB (left, right): left - right'.
  #mul -> 'MUL (left, right): left * right'.
  #div -> 'DIV (left, right): left / right'.
  #mod -> 'MOD (left, right): left % right'.
  #pow -> 'POW (left, right): left ^ right'.
  #neg -> 'NEG (ref, kneg): -ref'.
  #abs -> 'ABS (ref, kabs): abs(ref)'.
  #atan2 -> 'ATAN2 (left, right): atan2(left, right)'.
  #ldexp -> 'LDEXP (left, right): ldexp(left, right)'.
  #min -> 'MIN (left, right): min(left, right)'.
  #max -> 'MAX (left, right): max(left, right)'.
  #fpmath -> 'FPMATH (ref, #fpm): fpmath(ref)'.
  #addov -> 'ADDOV (left, right): left + right, overflow-checked'.
  #subov -> 'SUBOV (left, right): left - right, overflow-checked'.
  #mulov -> 'MULOV (left, right): left * right, overflow-checked'.
  #fpm_floor -> 'FPM_FLOOR       floor(ref)'.
  #fpm_ceil -> 'FPM_CEIL        ceil(ref)'.
  #fpm_trunc -> 'FPM_TRUNC       trunc(ref)'.
  #fpm_sqrt -> 'FPM_SQRT        sqrt(ref)'.
  #fpm_exp -> 'FPM_EXP         exp(ref)'.
  #fpm_exp2 -> 'FPM_EXP2        exp2(ref)'.
  #fpm_log -> 'FPM_LOG         log(ref)'.
  #fpm_log2 -> 'FPM_LOG2        log2(ref)'.
  #fpm_log10 -> 'FPM_LOG10       log10(ref)'.
  #fpm_sin -> 'FPM_SIN         sin(ref)'.
  #fpm_cos -> 'FPM_COS         cos(ref)'.
  #fpm_tan -> 'FPM_TAN         tan(ref)'.
  #aref -> 'AREF (array, index): Array reference'.
  #hrefk -> 'HREFK (hash, kslot): Constant hash reference'.
  #href -> 'HREF (tab, key): Hash reference'.
  #newref -> 'NEWREF (tab, key): Create new reference'.
  #urefo -> 'UREFO (func, #uv): Open upvalue reference'.
  #urefc -> 'UREFC (func, #uv): Closed upvalue reference'.
  #fref -> 'FREF (obj, #field): Object field reference'.
  #strref -> 'STRREF (str, index): String reference'.
  #aload -> 'ALOAD (aref): Array load'.
  #hload -> 'HLOAD (href): Hash load'.
  #uload -> 'ULOAD (uref): Upvalue load'.
  #fload -> 'FLOAD (obj, #field): Object field load'.
  #xload -> 'XLOAD (xref, #flags): Extended load'.
  #sload -> 'SLOAD (#slot, #flags): Stack slot load'.
  #vload -> 'VLOAD (aref): Vararg slot load'.
  #astore -> 'ASTORE (aref, val): Array store'.
  #hstore -> 'HSTORE (href, val): Hash store'.
  #ustore -> 'USTORE (uref, val): Upvalue store'.
  #fstore -> 'FSTORE (fref, val): Object field store'.
  #xstore -> 'XSTORE (xref, val): Extended store'.
  #snew -> 'SNEW (data, length): Allocate interned string'.
  #xsnew -> 'XSNEW (data, length): Allocate interned string from cdata'.
  #tnew -> 'TNEW (#asize, #hbits): Allocate Lua table with minimum array and hash sizes'.
  #tdup -> 'TDUP (template): Allocate Lua table, copying a template table'.
  #cnew -> 'CNEW (ctypeid, size): Allocate mutable cdata'.
  #cnewi -> 'CNEWI (ctypeid, val): Allocate immutable cdata'.
  #tbar -> 'TBAR (tab): Table write barrier'.
  #obar -> 'OBAR (obj, val): Object write barrier'.
  #xbar -> 'XBAR: XLOAD/XSTORE optimization barrier'.
  #conv -> 'CONV (src, #flags): Generic type conversion'.
  #tobit -> 'TOBIT (num, bias): Convert double to integer with Lua BitOp semantics'.
  #tostr -> 'TOSTR (number): Convert double or integer to string'.
  #strto -> 'STRTO (str): Convert string to double'.
  #calln -> 'CALLN (args, #ircall): Call internal function (normal)'.
  #calll -> 'CALLL (args, #ircall): Call internal function (load)'.
  #calls -> 'CALLS (args, #ircall): Call internal function (store)'.
  #callxs -> 'CALLXS (args, func): Call external function (store/barrier)'.
  #carg -> 'CARG (args, arg): Call argument extension'.
  #nop -> 'NOP: No operation'.
  #base -> 'BASE (#parent, #exit): BASE reference, link to parent side exit'.
  #pval -> 'PVAL (#pref): Parent value reference'.
  #gcstep -> 'GCSTEP: Explicit GC step'.
  #hiop -> 'HIOP (left, right): Hold hi-word operands of split instructions'.
  #loop -> 'LOOP: Separator before loop-part of a trace'.
  #use -> 'USE (ref): Explicit use of a reference'.
  #phi -> 'PHI (left, right): PHI node for loops'.
  #rename -> 'RENAME (ref, #snap): Renamed reference below snapshot'.
} asDictionary.
]

{ #category : #roassal }
RJITIRInstruction >> asElement [
	^ self shape elementOn: self.
]

{ #category : #initialization }
RJITIRInstruction >> attributes [
	^ {
		'Code' -> self irString.
		'Type' -> type.
		'Opcode' -> opcode.
		}
]

{ #category : #accessing }
RJITIRInstruction >> constantValue [
	self shouldBeImplemented.
]

{ #category : #initialization }
RJITIRInstruction >> gtInspectorIRInstructionIn: composite [
	<gtInspectorPresentationOrder: 1>
	composite table
		title: 'Info';
		display: [ self attributes ];
		column: 'Key' evaluated: #key width: 100;
		column: 'Value' evaluated: #value.

]

{ #category : #initialization }
RJITIRInstruction >> gtInspectorInputListingIn: composite [
	<gtInspectorPresentationOrder: 2>
	composite fastList
		title: 'Input List';
		display: [ self transitiveInputs asArray];
		format: #irString.

]

{ #category : #initialization }
RJITIRInstruction >> gtInspectorInputTreeIn: composite [
	<gtInspectorPresentationOrder: 3>
	composite roassal2
		title: 'Input Tree';
		initializeView: [ trace irTreeViewOfInstructions: self transitiveInputs ].

]

{ #category : #initialization }
RJITIRInstruction >> index [
	^ index
]

{ #category : #initialization }
RJITIRInstruction >> index: i [
	index := i
]

{ #category : #initialization }
RJITIRInstruction >> irIns: dwValue [
	| v |
	dwarf := dwValue dwarf.
	irIns := dwValue.
	v := DWARFValueProxy on: dwValue.
	opcode := (dwarf valueToName: v o inEnumerationWith: 'IR_NOP') asIRInstructionName.
	type := (dwarf valueToName: ((v t irt) bitAnd: 16r1f) inEnumerationWith: 'IRT_NIL') asIRInstructionType.
	mode := dwValue flashback auditLog irModes at: v o.
	register := v r.
	stackSlot := v s.
	op1 := v op1.
	op2 := v op2.
	op12 := v op12.
	isPhiOperand := false. "Initial value"
]

{ #category : #printing }
RJITIRInstruction >> irRefString [
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
]

{ #category : #printing }
RJITIRInstruction >> irRegisterString [
	self isSunk ifTrue: [ ^ '{sink' ].
	stackSlot > 0 ifTrue: [ ^ '[{1}]' format: { stackSlot radix: 16 } ].
	register < 128 ifTrue: [ ^ register asX64RegisterAssignment ].
	^ ''. "None"

]

{ #category : #printing }
RJITIRInstruction >> irString [
	"LOOP is a special case"
	opcode = #loop ifTrue: [ ^ self irRefString , ' ------ LOOP ------------' ].
	^ String streamContents: [ :s |
		s
			nextPutAll: self irRefString;
			space;
			nextPutAll: (self irRegisterString padRightTo: 6);
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
 
]

{ #category : #initialization }
RJITIRInstruction >> isAllocation [
	^ #(snew xsnew tnew tdup cnew cnewi) includes: opcode.

]

{ #category : #initialization }
RJITIRInstruction >> isArithmetic [
	^ #(add sub mul div mod pow neg abs atan2 ldexp min max fpmath addov subov mulov) includes: opcode
]

{ #category : #initialization }
RJITIRInstruction >> isBarrier [
	^ #(tbar obar xbar) includes: opcode.
]

{ #category : #initialization }
RJITIRInstruction >> isBitOp [
	^ #(bnot bswap band bor bxor bshl bshr bsar brol bror) includes: opcode.
]

{ #category : #initialization }
RJITIRInstruction >> isCall [
	^ #(calln calll calls callxs carg) includes: opcode.
]

{ #category : #initialization }
RJITIRInstruction >> isConstant [
	^ #(kpri kint kgc kptr kkptr knull knum kint64 kslot) includes: opcode.

]

{ #category : #initialization }
RJITIRInstruction >> isGuardedAssertion [
	^ #(lt ge le gt ult uge ule ugt eq ne abc retf) includes: opcode.

]

{ #category : #initialization }
RJITIRInstruction >> isLoad [
	^ #(aload hload uload fload xload sload vload) includes: opcode.

]

{ #category : #initialization }
RJITIRInstruction >> isLoadStore [
	^ self isLoad or: [ self isStore ].

]

{ #category : #testing }
RJITIRInstruction >> isLoop [
	^ opcode = #loop.
]

{ #category : #initialization }
RJITIRInstruction >> isMemoryReference [
	^ #(aref hrefk href newref urefo urefc fref strref) includes: opcode.
]

{ #category : #initialization }
RJITIRInstruction >> isMisc [
	^ #(nop base pval gcstep hiop loop use phi rename) includes: opcode.
]

{ #category : #initialization }
RJITIRInstruction >> isNop [
	^ opcode = #nop

]

{ #category : #initialization }
RJITIRInstruction >> isStore [
	^ #(astore hstore ustore fstore xstore) includes: opcode.
]

{ #category : #testing }
RJITIRInstruction >> isSunk [
	"Logic copied from LuaJIT dump.lua"
	^ (#(253 254) includes: register) and: 
		[ #(0 255) includes: stackSlot ].

]

{ #category : #initialization }
RJITIRInstruction >> isTypeConversion [
	^ opcode matchesRegex: 'conv|tobit|tostr|strto'.
]

{ #category : #accessing }
RJITIRInstruction >> link: aGCtrace [
	trace := aGCtrace.
	mode op1mode = #ref ifTrue: [ op1ins := self resolveIR: op1 in: aGCtrace ].
	mode op2mode = #ref ifTrue: [ op2ins := self resolveIR: op2 in: aGCtrace ].
	opcode = 'phi' ifTrue: [ 
		op1ins ifNotNil: #setPhiOperand.
		op2ins ifNotNil: #setPhiOperand. ]
]

{ #category : #accessing }
RJITIRInstruction >> op1 [
	^ op1 ifNil: [ op12 ].
]

{ #category : #accessing }
RJITIRInstruction >> op1ins [
	^ op1ins
]

{ #category : #accessing }
RJITIRInstruction >> op2 [
	^ op2
]

{ #category : #accessing }
RJITIRInstruction >> op2ins [
	^ op2ins
]

{ #category : #accessing }
RJITIRInstruction >> opcode [
	^ opcode
]

{ #category : #initialization }
RJITIRInstruction >> popupSummary [
	^ (RJITIRInstruction opcodeSummaries at: opcode ifAbsent: [ '(unknown opcode)' ]) ,
		Character cr asString,
		self irString.
]

{ #category : #initialization }
RJITIRInstruction >> printOn: aStream [
	super printOn: aStream.
   aStream nextPutAll: ' (', opcode, ' <', type, '>)'.
]

{ #category : #initialization }
RJITIRInstruction >> register [
	^ register
]

{ #category : #initialization }
RJITIRInstruction >> resolveIR: num in: aGCtrace [
	| bias idx |
	trace := aGCtrace.
	bias := dwarf resolveConstant: 'REF_BIAS'.
	idx := num - bias.
	idx >= 0
		ifTrue: [ ^ aGCtrace irInstructions at: idx ifAbsent: [nil] ]
		ifFalse: [ ^ aGCtrace irConstants at: 0 - idx ifAbsent: [nil] ].

]

{ #category : #initialization }
RJITIRInstruction >> roassalColor [	
	self isAllocation ifTrue: [
		^ self isSunk ifTrue: [ Color pink ] ifFalse: [ Color red ].
	].
	self isArithmetic ifTrue: [ ^Color paleGreen. ].
	self isBitOp ifTrue: [ ^Color paleGreen darker. ].
	"Calls"
	self isBarrier ifTrue: [ ^Color orange lighter. ].
	self isCall ifTrue: [ ^Color orange. ].
	"Checks and conversions."
	self isGuardedAssertion ifTrue: [ ^Color palePeach. ].
	self isTypeConversion ifTrue: [ ^Color palePeach darker. ].	
	"Memory access"
	self isMemoryReference ifTrue: [ ^ Color paleBlue. ].
	self isLoad ifTrue: [ ^ Color paleBlue darker. ].
	self isStore ifTrue: [ ^ Color paleBlue darker darker. ].
	self isLoop ifTrue: [ ^ Color transparent. ].
	self isMisc ifTrue: [ ^ Color paleGreen. ].
	^ Color cyan. "unrecognized"
]

{ #category : #initialization }
RJITIRInstruction >> roassalElement [
	^ RTBox new size: 20 ; color: self roassalColor; elementOn: self.

]

{ #category : #initialization }
RJITIRInstruction >> roassalShape [
	^ RTBox.

]

{ #category : #initialization }
RJITIRInstruction >> setPhiOperand [
	isPhiOperand := true.
]

{ #category : #roassal }
RJITIRInstruction >> shape [
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
]

{ #category : #initialization }
RJITIRInstruction >> stackSlot [
	^ stackSlot
]

{ #category : #querying }
RJITIRInstruction >> transitiveInputs [
	^ trace transitiveInputsOf: self.
]

{ #category : #initialization }
RJITIRInstruction >> type [
	^ type
]
