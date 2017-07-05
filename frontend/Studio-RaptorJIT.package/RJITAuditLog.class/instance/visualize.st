visualization
visualize
	| view traces es |
	view := RTView new.
	traces := self traces.
	es := (RTLabel new text: [ :e | 'Trace ', e traceno asString ]) +
			(RTBox new size: 10; color: Color transparent; borderColor: Color black)
				elementsOn: traces.
	view addAll: es.
	RTNest new
		for: es
		add: [ :group :model |
			group addAll: (RTBox new color: #roassalColor; elementsOn: model irInstructions).
			RTGridLayout on: group ].
	RTEdgeBuilder new
		view: view;
		objects: traces;
		shape:
			(RTLine new
				attachPoint: RTShorterDistanceAttachPoint new;
				color: Color veryDarkGray)
				+
					(RTSimpleArrowHead new
						attachPoint: RTShorterDistanceAttachPoint new;
						color: Color veryDarkGray);
		connectFrom: #root to: #yourself.
	RTHorizontalTreeLayout on: es.
	view @ RTZoomableBoxView.
	^view.