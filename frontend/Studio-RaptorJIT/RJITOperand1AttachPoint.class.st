Class {
	#name : #RJITOperand1AttachPoint,
	#superclass : #RTHorizontalAttachPoint,
	#category : #'Studio-RaptorJIT'
}

{ #category : #'public - hooks' }
RJITOperand1AttachPoint >> basicEndingPointOf: aRTEdge [
	^ aRTEdge to encompassingRectangle topLeft
]

{ #category : #'public - hooks' }
RJITOperand1AttachPoint >> basicStartingPointOf: aRTEdge [
	^ aRTEdge from encompassingRectangle bottomCenter
]
