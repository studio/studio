Class {
	#name : #RJITBlIRFragment,
	#superclass : #BlElement,
	#instVars : [
		'irInstructions',
		'irElems',
		'testNodes',
		'testEdges'
	],
	#category : #'Studio-RaptorJIT'
}

{ #category : #'as yet unclassified' }
RJITBlIRFragment class >> forIrInstructions: irInstructions [
	^ self new irInstructions: irInstructions.
]

{ #category : #'as yet unclassified' }
RJITBlIRFragment class >> forTrace: aTrace [
	^ self forIrInstructions: aTrace irInstructions.
]

{ #category : #accessing }
RJITBlIRFragment >> irInstructions: irInstructionList [
	irInstructions := irInstructionList.
	irElems := (irInstructions collect: [ :ins | ins -> ins asElement ]) asDictionary.
	self layoutInstructions.
]

{ #category : #accessing }
RJITBlIRFragment >> layoutInstructions [
	"Add layout constraints for edges between instructions."
	testNodes := irElems keys collect: [ :ins | ins index asString  ].
	testEdges := irElems keys flatCollect: [ :ins |
		| x |
		x := OrderedCollection new.
		ins op1ins ifNotNil: [ :op | x add: (op index asString) -> ins index asString ].
		ins op2ins ifNotNil: [ :op | x add: (op index asString) -> ins index asString ].
		x
		 ].
	irElems keysAndValuesDo: [ :ins :elem |
		self addChild: elem.
		elem graph beNode.
		{ ins op1ins. ins op2ins. } do: [ :op |
			op ifNotNil: [ 
				(irElems includesKey: op) ifTrue: [ 
					| opElem line edge |
					opElem := irElems at: op.
					line := BlLineElement new.
					line constraintsDo: [ :c | c ignoreByLayout ].
					line
						zIndex: -1;
						border: (BlBorder paint: Color black);
						fromAnchor: (BlElementBottomCenterAnchor element: opElem opcode);
						toAnchor: (op = ins op1ins ifTrue: [ BlElementTopLeftAnchor element: elem ] ifFalse: [ BlElementTopRightAnchor element: elem ]).
					self addChild: line.
					edge := GtGraphEdge new from: (irElems at: op) to: elem.
					elem constraintsDo: [ :c | c graph addConnectedEdge: edge ].
					(irElems at: op) constraintsDo: [ :c | c graph addConnectedEdge: edge ].
				 ]
				] 
			]
		 ].
	self
"		layout: GtGraphTreeLayout new."
		layout: (GtGradNorthHierarchicalTreeLayout new levelDistance: 5).
"		layout: (GtGradNorthHierarchicalLayout new interRanksSpacing: 20)."
	self constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent. ].
]
