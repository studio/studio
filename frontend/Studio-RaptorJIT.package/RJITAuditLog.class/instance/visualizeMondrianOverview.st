visualization
visualizeMondrianOverview
	| b |
	b := RTMondrian new.
	b shape rectangle
		borderColor: Color black;
		color: Color transparent.
	b nodes: (self traces groupedBy: [ :x | x root ifNil: [ Object new ] ])
		forEach: [ :group |
		b shape rectangle
			color: Color lightBlue;
			borderColor: Color black;
			size: [ :x | x irInstructions size sqrt * 10];
			withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
		b nodes: group value.
		b layout dominanceTree.
		b edges connectFrom: #parent. ].
	b nodes size > 3 ifTrue: [ b layout packed ] ifFalse: [ b layout force ].
	^ b build.
