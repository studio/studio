gt-inspector-extension
gtInspectorIRTreeOldIn: composite
	<gtInspectorPresentationOrder: 9>
	composite roassal2
		title: 'IR Tree (Old)';
		initializeView: [
			| b |
			b := RTMondrian new.
			b shape rectangle color: Color transparent; borderColor: Color gray.
			b nodes: { self headInstructions. self loopInstructions. }
			  forEach: [ :insns |
					b shape rectangle
						color: #roassalColor;
						size: 50;
						withText: #opcode height: 12 color: Color veryDarkGray.
					b nodes: insns.
					b shape line withOperand1AttachPoint.
					b edges connectFrom: #op1ins.
					b shape line withOperand2AttachPoint.
					b edges connectFrom: #op2ins.
					b layout dominanceTree doNotAttachPoint verticalGap: 20.
				 ].
			b layout verticalLine.
			b build.
		].
