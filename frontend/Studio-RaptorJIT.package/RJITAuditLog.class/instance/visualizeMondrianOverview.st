visualization
visualizeMondrianOverview
	| b groups |
	groups := self traces groupedBy: [ :x | x root ifNil: [ Object new ] ].
	b := RTMondrian new.
	b shape rectangle
		borderColor: Color black;
		color: Color transparent.
	b nodes: groups
		forEach: [ :group |
		b shape rectangle
			color: Color lightBlue;
			borderColor: Color black;
			size: [ :x | x numberOfIrInstructions sqrt * 10];
			withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
		b nodes: group value.
		b layout dominanceTree.
		b edges connectFrom: #parent. ].
	groups size >= 3 ifTrue: [ b layout packed ] ifFalse: [ b layout force ].
	^ b build.
