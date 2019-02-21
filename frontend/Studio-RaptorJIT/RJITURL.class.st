Class {
	#name : #RJITURL,
	#superclass : #Object,
	#category : #'Studio-RaptorJIT'
}

{ #category : #converting }
RJITURL >> asElement [
	^ BrLabel new text: 'URL:'; look: BrGlamorousLabelLook.

]

{ #category : #converting }
RJITURL >> example [
	<gtExample>
	^ self
]

{ #category : #converting }
RJITURL >> gtFormFor: aView [
	<gtView>
	^aView explicit 
		title: 'Form';
		stencil: [ 
			BrLabel new text: 'URL:'; look: BrGlamorousLabelLook ].

]
