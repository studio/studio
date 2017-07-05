visualization
visualizeMondrianWithProfile: aVMProfile 
	| b m traces |
	b := RTMondrian new.
	b shape
		rectangle
		borderColor: Color black;
"		color: [ :tr | Color red alpha: (aVMProfile traceAll: tr traceno). ];"
		withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
	traces := self traces select: [ :tr | (aVMProfile traceAll: tr traceno) > 0.05 ].
	b
		nodes: traces
		forEach: [ :tr | |head loop|
			head := tr headInstructions select: [ :ins | (#(nop) includes: ins opcode) not ].
			loop := tr loopInstructions select: [ :ins | (#(nop) includes: ins opcode) not ].
			b shape rectangle
				borderColor: Color black;
				color: [ :insns |
				insns = head
							ifTrue:  [ Color red alphaMixed: (aVMProfile traceHead: tr traceno) with: Color white. ]
							ifFalse: [ Color red alphaMixed: (aVMProfile traceLoop: tr traceno) with: Color white. ]. ].
				b
				nodes: (tr hasLoop ifTrue: { head. loop. } ifFalse: { head. })
				forEach: [ :insns |
					b shape rectangle
						color: #roassalColor;
						borderColor: [ :ins | ins stackSlot = 0 ifTrue: [ Color transparent. ] ifFalse: [ Color black. ] ];
						width: 50;
						height: 20;
						withText: #opcode height: 12 color: Color veryDarkGray.
					b nodes: insns.
					"b shape arrowedBezier width: 0.1."
					b shape
						line
						color: (Color black alpha: 0.33);
						withOperand1AttachPoint.
					b edges connectFrom: #op1ins.
					b shape
						line
						color: (Color black alpha: 0.33);
						withOperand2AttachPoint.
					b edges connectFrom: #op2ins.
					b layout dominanceTree doNotAttachPoint verticalGap: 15 ]. ].
	b edges connectFrom: #root.
	b layout horizontalTree.
	m := b build.
	m view @ RTZoomableBoxView.
	^ m
