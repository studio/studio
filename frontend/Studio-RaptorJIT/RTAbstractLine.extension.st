Extension { #name : #RTAbstractLine }

{ #category : #'*studio-raptorjit' }
RTAbstractLine >> withOperand1AttachPoint [
	| ap |
	ap := RJITOperand1AttachPoint new.
	self attachPoint: ap.
	^ ap
]

{ #category : #'*studio-raptorjit' }
RTAbstractLine >> withOperand2AttachPoint [
	| ap |
	ap := RJITOperand2AttachPoint new.
	self attachPoint: ap.
	^ ap
]
