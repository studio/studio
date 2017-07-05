initializing
roassal
	| view elements head loop headIns loopIns insShape shapeContainer shapeIns headLabel loopLabel line border |
	view := RTView new.
	"Border surrounding the trace."
	border := RTBox new width: 250; color: Color transparent; borderColor: Color black; element.
	"Containers for the head and loop with a separating line."
	shapeContainer := RTBox new width: 200; color: Color transparent; yourself.
	head := shapeContainer element.
	loop := shapeContainer element.
	line := RTBox new extent: 250@1; element.
	"Shapes for the individual instructions."
	shapeIns := (RTBox new size: 20; color: [ :e | e roassalColor ]).
	headIns := (shapeIns elementsOn: self headInstructions).
	loopIns := shapeIns elementsOn: self loopInstructions.
	"Put everything into the view."
	view add: border; add: head; add: loop; addAll: headIns; addAll: loopIns; add: line.
	"Apply layout."
	headIns @ (RTLabeled center text: #opcode).
	RTGridLayout new lineItemsCount: 10; on: headIns; on: loopIns.
	RTVerticalLineLayout new on: { head. line. loop. }.
	RTVerticalLineLayout new on: { border. }.
	"Setup nesting."
	RTNest new
	   on: head nest: headIns; 
	   on: loop nest: loopIns;
	   on: border nest: { head. line. loop. }.
	"Final tweaks."
	border width: 250.
	RTAlignment new elements: { head. loop. }; left.
   ^view