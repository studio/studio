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
		'trace',
		'mcode',
		'szmcode',
		'mcodeAddress',
		'phiParent',
		'phiChild'
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
	^ RJITBlIRInstruction for: self
]

{ #category : #initialization }
RJITIRInstruction >> attributes [
	^ {
		'Code' -> self irString.
		'Type' -> type.
		'Opcode' -> opcode.
		}
]

{ #category : #roassal }
RJITIRInstruction >> baseBlShape [
	| container shape |

	container := BlElement new
		layout: BlFrameLayout new;
		border: self blBorder;
		background: self opcodeColor; 
		width: 50;
		height: 20.

	shape := BlTextElement new
					text: self opcode asRopedText glamorousCodeFont;
					constraintsDo: [ :c |
						c frame vertical alignCenter.
						c frame horizontal alignCenter. ].

	"no mcode border dashed"
	"isSpilledOntoStack border bold"

	container addChild: shape.
	
	^ container
]

{ #category : #roassal }
RJITIRInstruction >> blBorder [
	| builder |
	builder := BlBorder builder paint: Color black.
	self isSpilledOntoStack ifTrue: [ builder width: 2 ].
	szmcode = 0 ifTrue: [ builder dashed ].
	^ builder build.

]

{ #category : #bloc }
RJITIRInstruction >> blInlineText: aString [
	| container text |

	container := BlElement new
		layout: BlFrameLayout new;
		border: (BlBorder paint: Color gray);
		padding: (BlInsets left: 5 right: 5);
		constraintsDo: [ :c |
			c vertical matchParent.
			c horizontal matchParent. ].

	text := BlTextElement new 
			text: aString asRopedText glamorousCodeFont;
			constraintsDo: [ :c |
				c frame vertical alignCenter.
				c frame horizontal alignCenter. ].
			
	container addChild: text.

	^ container
]

{ #category : #bloc }
RJITIRInstruction >> blShape [
	| el |
	el := BlElement new.
	self op1InlineString ifNotNil: [ :s | el addChild: (self blInlineText: s) ].
	el addChild: self baseBlShape as: #opcode.
	self op2InlineString ifNotNil: [ :s | el addChild: (self blInlineText: s) ].
	el constraintsDo: [ :c | c horizontal fitContent. c vertical fitContent. ].
	el layout: (BlLinearLayout horizontal).	
	^ el
]

{ #category : #accessing }
RJITIRInstruction >> constantValue [
	self shouldBeImplemented.
]

{ #category : #initialization }
RJITIRInstruction >> disassemble [
	^ trace disassembleFrom: mcodeAddress to: mcodeAddress + mcode size.

]

{ #category : #initialization }
RJITIRInstruction >> gtInputsListingIn: aView [
	"<gtView>"
	^ (self transitiveInputs irColumnedListViewIn: aView title: 'Inputs' translated) priority: 11.

]

{ #category : #initialization }
RJITIRInstruction >> gtMCodeFor: aView [
	<gtView>
	^ aView textEditor 
		title: 'MCode';
		priority: 20;
		look: BrGlamorousCodeEditorLook;
		text: [ self disassemble asRopedText ]

]

{ #category : #initialization }
RJITIRInstruction >> gtRelatedGraphIn: aView [
	<gtView>
	^ aView explicit
		title: 'Related Graph';
		priority: 15;
		stencil: [ RJITBlIRFragment forIrInstructions: self transitiveRelations ].

]

{ #category : #initialization }
RJITIRInstruction >> gtRelatedListingIn: aView [
	<gtView>
	^ (self transitiveRelations irColumnedListViewIn: aView title: 'Related List' translated) priority: 10.

]

{ #category : #initialization }
RJITIRInstruction >> gtUsesListingIn: aView [
	"<gtView>"
	^ (self transitiveUses irColumnedListViewIn: aView title: 'Uses' translated) priority: 12.

]

{ #category : #initialization }
RJITIRInstruction >> index [
	^ index
]

{ #category : #initialization }
RJITIRInstruction >> index: i [
	index := i
]

{ #category : #printing }
RJITIRInstruction >> irFlagsString [
	^ (self isGuardedAssertion ifTrue: '>' ifFalse: ' ') ,
		(isPhiOperand ifTrue: '+' ifFalse: ' ').

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
	"This is a hairy function that should be refactored once its ideal structure becomes clear."
	self isConstant ifFalse: [ 
		^ index printStringLength: 4 padded: true.
	].
	"Constants"
	(opcode = #kpri and: type = #true)  ifTrue: [ ^ 'T' ].
	(opcode = #kpri and: type = #false) ifTrue: [ ^ 'F' ].
	(opcode = #kpri and: type = #nil)   ifTrue: [ ^ 'NULL' ].
	(opcode = #kgc)    ifTrue: [
		| ptr |
		ptr := (irIns flashback decodeTypeNamed: #uint64_t at: irIns address + 8) value.
		type = #str ifTrue: [
			[ ^ '''', (irIns flashback decodeLuaStringAt: ptr), '''' ]
				on: Error do: [ ] ].
		type = #func ifTrue: [ 
			[ | gcfunc protoPtr proto |
				gcfunc := irIns flashback decodeTypeNamed: #GCfunc at: ptr.
				protoPtr := ((gcfunc child: #l) value child: #pc) value value - (irIns dwarf typeNamed: #GCproto) byteSize.
				proto := irIns flashback decodeGCprotoAt: protoPtr.
				^ proto sourceName, ':', (proto bytecodeLine: 0) asString. ] on: RJITFlashbackDataMissing do: [] ] ].
	opcode = #kint64 ifTrue: [
		| v |
		v := irIns flashback decodeTypeNamed: 'int64_t' at: irIns address + 8.
		^ String streamContents: [ :s |
			v value >= 0 ifTrue: [ s nextPut: $+ ].
			s nextPutAll: v asString.
			v value <= (2 raisedTo: 48) ifTrue: [ s nextPutAll: ' (0x', (v value radix: 16), ')' ] ] ].
	opcode = #knull ifTrue: [ ^'NULL' ].
	(#(kptr kkptr) includes: opcode) ifTrue: [
		| v |
		v := irIns flashback decodeTypeNamed: 'uint64_t' at: irIns address + 8.
		^ '@0x', (v value radix: 16).		
	].
	opcode = #kint ifTrue: [ ^ (op12 sign = -1 ifTrue: ['-'] ifFalse: ['+']) , op12 printString ].
	opcode = #kslot ifTrue: [  op1ins ifNotNil: [ ^ op1ins irRefString ] ].
	opcode = #knum ifTrue: [ ^ (irIns flashback decodeTypeNamed: 'double' at: irIns address + 8) asString ].
	"XXX NYI"
	^ '<' , type , '>'
]

{ #category : #printing }
RJITIRInstruction >> irRegisterString [
	self isSunk ifTrue: [ ^ '{sink}' ].
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
			nextPutAll: (self typename padRightTo: 6);
			space;
			nextPutAll: (opcode padRightTo: 6).
		op1ins
			ifNotNil: [ s space; nextPutAll: (op1ins irRefString padRightTo: 5) ]
			ifNil: [ self op1InlineString ifNotNil: [ :str | s space; nextPutAll: str ] ].
		op2ins
			ifNotNil: [ s space; nextPutAll: (op2ins irRefString padRightTo: 5) ]
			ifNil: [ self op2InlineString ifNotNil: [ :str | s space; nextPutAll: str ] ].
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
RJITIRInstruction >> isPhi [
	^ opcode = #phi

]

{ #category : #initialization }
RJITIRInstruction >> isSpilledOntoStack [
	"Return true if the IR value is stored on the stack instead of in a register."
	^ stackSlot > 0
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
		op1ins ifNotNil: [
			op1ins setPhiOperand.
			op1ins phiChild: op2ins ].
		op2ins ifNotNil: [
			op2ins setPhiOperand.
			op2ins phiParent: op1ins ] ].
]

{ #category : #accessing }
RJITIRInstruction >> mcode: bytes [
	mcode := bytes
]

{ #category : #accessing }
RJITIRInstruction >> mcodeAddress: address [
	mcodeAddress := address
]

{ #category : #accessing }
RJITIRInstruction >> op1 [
	^ op1 ifNil: [ op12 ].
]

{ #category : #accessing }
RJITIRInstruction >> op12 [
	^ op12
]

{ #category : #accessing }
RJITIRInstruction >> op1InlineString [
	(#(cnew cnewi) includes: opcode) ifTrue: [
		^ '''', (irIns flashback auditLog ctypeName: op1ins op12), '''' ].
	#sload = opcode ifTrue: [
		^ '#' , op1 asString ].
	(op1ins ~= nil and: [ op1ins isConstant]) ifTrue: [ ^ op1ins irRefString ].
	^ nil
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
RJITIRInstruction >> op2InlineString [
	(#(urefo urefc) includes: opcode) ifTrue: [ 
		^ '#', op2 asString ].
	(#(fload fref) includes: opcode) ifTrue: [
		[ ^ (irIns dwarf valueToName: op2 inEnumerationWith: #IRFL__MAX) asIrFieldName ]
		  on: Error do: [] ].
	(#(calln calll calls) includes: opcode) ifTrue: [ 
		[ ^ (irIns dwarf valueToName: op2 inEnumerationWith: #IRCALL__MAX) asIrCallName ]
		  on: Error do: [] ].
	#fpmath = opcode ifTrue: [ 
		[ ^ (irIns dwarf valueToName: op2 inEnumerationWith: #IRFPM__MAX) asIrFloatOperationName ]
		  on: NotFound do: [] ].
	#sload = opcode ifTrue: [ 
		^ String streamContents: [ :s |
			{ 1->$P. 2->$F. 4->$T. 8->$C. 16->$R. 32->$I. } do: [ :a |
				(op2 bitAt: a key) = 1 ifTrue: [ s nextPut: a value ] ]
			 ] ].
	#xload = opcode ifTrue: [ 
		^ (#(R V RV U RU VU RVU) at: op2+1) asString ].
	(op2ins ~= nil and: [ op2ins isConstant ]) ifTrue: [ ^ op2ins irRefString ].
	^ nil
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
RJITIRInstruction >> opcodeColor [
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

{ #category : #'as yet unclassified' }
RJITIRInstruction >> operand1String [
	^ String streamContents: [ :s |
		op1ins ifNotNil: [ s nextPutAll: (op1ins irRefString padRightTo: 5) ].
		self op1InlineString ifNotNil: [ :str | ^ s nextPutAll: str ] ]
	
]

{ #category : #'as yet unclassified' }
RJITIRInstruction >> operand2String [
	^ String streamContents: [ :s |
		op2ins ifNotNil: [ s nextPutAll: (op2ins irRefString padRightTo: 5) ].
		self op2InlineString ifNotNil: [ :str | ^ s nextPutAll: str ] ]
]

{ #category : #'as yet unclassified' }
RJITIRInstruction >> operandsString [
	opcode = #loop ifTrue: [ ^ '-----------------------------------------' ].
	^ self operand1String , String space, self operand2String.

]

{ #category : #accessing }
RJITIRInstruction >> phiChild [
	^ phiChild
]

{ #category : #accessing }
RJITIRInstruction >> phiChild: ins [
	phiChild := ins
]

{ #category : #accessing }
RJITIRInstruction >> phiParent [
	^ phiParent
]

{ #category : #accessing }
RJITIRInstruction >> phiParent: ins [
	phiParent := ins
]

{ #category : #initialization }
RJITIRInstruction >> popupSummary [
	^ (RJITIRInstruction opcodeSummaries at: opcode ifAbsent: [ '(unknown opcode)' ]) ,
		Character cr asString,
		self irString,
		Character cr asString, Character cr asString,
		self disassemble.
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
	^ self opcodeColor
]

{ #category : #initialization }
RJITIRInstruction >> setPhiOperand [
	isPhiOperand := true.
]

{ #category : #initialization }
RJITIRInstruction >> stackSlot [
	^ stackSlot
]

{ #category : #printing }
RJITIRInstruction >> szmcode [
	^ szmcode
]

{ #category : #accessing }
RJITIRInstruction >> szmcode: size [
	szmcode := size
]

{ #category : #testing }
RJITIRInstruction >> test [
	^{
		self gtInputsListingIn: GtPhlowView empty.
		self gtRelatedListingIn: GtPhlowView empty.
		self gtUsesListingIn: GtPhlowView empty.
	}.
]

{ #category : #querying }
RJITIRInstruction >> transitiveInputs [
	^ trace transitiveInputsOf: self.
]

{ #category : #accessing }
RJITIRInstruction >> transitiveRelations [
	^ (self transitiveInputs union: self transitiveUses) sort: [ :a :b | a index < b index ]
]

{ #category : #querying }
RJITIRInstruction >> transitiveUses [
	^ trace transitiveUsesOf: self.
]

{ #category : #initialization }
RJITIRInstruction >> type [
	^ type
]

{ #category : #accessing }
RJITIRInstruction >> typename [
	type = #nil ifTrue: [ ^ '' ].
	type = #num ifTrue: [ ^ 'float' ].
	type = #pgc ifTrue: [ ^ 'obj' ].
	type = #p64 ifTrue: [ ^ 'ptr' ].
	^ type
]
