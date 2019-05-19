Class {
	#name : #RJITBlIRInstruction,
	#superclass : #BlElement,
	#instVars : [
		'irIns',
		'opcode'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'instance creation' }
RJITBlIRInstruction class >> for: anIrIns [
	^ self new irIns: anIrIns
]

{ #category : #initialization }
RJITBlIRInstruction >> addChildFromInlineStringIfNotNil: aString [
	aString ifNotNil: [ self addChild: (self blInlineText: aString) ].

]

{ #category : #initialization }
RJITBlIRInstruction >> blBorder [
	| builder |
	builder := BlBorder builder paint: Color black.
	irIns isSpilledOntoStack ifTrue: [ builder width: 2 ].
	irIns szmcode = 0 ifTrue: [ builder dashed ].
	^ builder build.

]

{ #category : #initialization }
RJITBlIRInstruction >> blInlineText: aString [
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

{ #category : #initialization }
RJITBlIRInstruction >> blOpcode [
	| container shape |

	container := BlElement new
		layout: BlFrameLayout new;
		border: self blBorder;
		background: irIns opcodeColor; 
		width: 50;
		height: 20.

	shape := BlTextElement new
					text: irIns opcode asRopedText glamorousCodeFont;
					constraintsDo: [ :c |
						c frame vertical alignCenter.
						c frame horizontal alignCenter. ].

	"no mcode border dashed"
	"isSpilledOntoStack border bold"

	container addChild: shape.
	
	^ container
]

{ #category : #initialization }
RJITBlIRInstruction >> initializeChildren [
	self addChildFromInlineStringIfNotNil: irIns op1InlineString.
	opcode := self blOpcode.
	self addChild: opcode.
	self addChildFromInlineStringIfNotNil: irIns op2InlineString.
	self constraintsDo: [ :c | c horizontal fitContent. c vertical fitContent. ].
	self layout: (BlLinearLayout horizontal).

]

{ #category : #intialization }
RJITBlIRInstruction >> initializeEvents [
	self when: BlClickEvent do: [ :e |
		self phlow spawnObject: irIns ]
]

{ #category : #initialization }
RJITBlIRInstruction >> irIns: anIrIns [
	irIns := anIrIns.
	self initializeChildren.
	self initializeEvents.
]

{ #category : #accessing }
RJITBlIRInstruction >> opcode [
	^ opcode
]
