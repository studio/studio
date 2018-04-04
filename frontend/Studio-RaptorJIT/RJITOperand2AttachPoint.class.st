Class {
	#name : #RJITOperand2AttachPoint,
	#superclass : #RTHorizontalAttachPoint,
	#category : #'Studio-RaptorJIT'
}

{ #category : #'public - hooks' }
RJITOperand2AttachPoint >> basicEndingPointOf: aRTEdge [
	^ aRTEdge to encompassingRectangle topRight
]

{ #category : #'public - hooks' }
RJITOperand2AttachPoint >> basicStartingPointOf: aRTEdge [
	^ aRTEdge from encompassingRectangle bottomCenter
]
