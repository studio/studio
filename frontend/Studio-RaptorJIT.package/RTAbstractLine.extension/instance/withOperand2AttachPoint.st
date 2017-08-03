*studio-raptorjit
withOperand2AttachPoint
	| ap |
	ap := RJITOperand2AttachPoint new.
	self attachPoint: ap.
	^ ap