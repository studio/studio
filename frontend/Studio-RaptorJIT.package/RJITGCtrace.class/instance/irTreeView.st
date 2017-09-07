gt-inspector-extension
irTreeView
	| view head loop all separator popup |
	head := RTGroup new addAll: (self headInstructions collect: #asElement); yourself.
	loop := RTGroup new addAll: (self loopInstructions collect: #asElement); yourself.
	all := RTGroup new addAll: head; addAll: loop; yourself.
	separator := RTLabel new elementOn: #'LOOP:'.
	view := RTView new.
	view addAll: all; addAll: loop.
	
	popup := RTPopup new
		text: #popupSummary;
		alphaPopupBackground: 1.0;
		borderColor: Color black;
		backgroundColor: Color white.
	all @ popup.
	
	view @ RTZoomableBoxView.
	view @ RTDoubleScrollBar.
	RTEdgeBuilder new
		view: view;
		objects: (self irInstructions);
		shape: (RTLine new color: Color black trans; attachPoint: RJITOperand1AttachPoint new; yourself);
		connectFrom: #op1ins;
		shape: (RTLine new color: Color black trans; attachPoint: RJITOperand2AttachPoint new; yourself);
		connectFrom: #op2ins.
	RTDominanceTreeLayout new doNotAttachPoint; on: head.
	RTDominanceTreeLayout new doNotAttachPoint; on: loop.
	self hasLoop ifTrue: [ 
		view add: separator.
		RTVerticalLineLayout on: { head. separator. loop }. ].
	^ view 