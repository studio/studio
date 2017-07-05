*studio-raptorjit
withOperand1AttachPoint
	| ap |
	ap := RJITOperand1AttachPoint new.
	self attachPoint: ap.
	^ ap