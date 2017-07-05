visualization
visualizeMondrian
	| b m |
	b := RTMondrian new.
	b shape rectangle withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
	b
		nodes: self traces
		forEach: [ :tr |
			b nodes: (tr hasLoop
							ifTrue:  [ { tr headInstructions. tr loopInstructions select: [ :ins | (#(nop) includes: ins opcode) not ]. } ]
							ifFalse: [ { tr headInstructions. } ])
			forEach: [ :insns |
				b shape rectangle
					color: #roassalColor;
					withText: #opcode height: 1.
				b nodes: insns.
				"b shape arrowedBezier width: 0.1."
				b shape verticalBezierLine width: 0.1; color: (Color black alpha: 0.25).
				b edges connectFrom: #op1ins.
				b edges connectFrom: #op2ins.
				b layout dominanceTree verticalGap: 3 ]. ].
	b edges connectFrom: #root.
	b layout horizontalTree.
	m := b build.
	m view @ RTZoomableBoxView.
	^ m