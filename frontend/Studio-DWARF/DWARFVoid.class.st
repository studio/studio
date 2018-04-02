Class {
	#name : #DWARFVoid,
	#superclass : #Object,
	#category : #'Studio-DWARF'
}

{ #category : #accessing }
DWARFVoid class >> byteSize [
	^ 0
]

{ #category : #accessing }
DWARFVoid class >> typename [
	^'void'.
]

{ #category : #initialization }
DWARFVoid >> typename [
   ^'void'
]
