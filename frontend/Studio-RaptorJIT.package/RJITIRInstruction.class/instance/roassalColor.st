initialization
roassalColor	
	self isAllocation ifTrue: [ ^Color red. ].
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