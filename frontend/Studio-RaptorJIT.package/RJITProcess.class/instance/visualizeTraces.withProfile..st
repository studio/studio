visualization
visualizeTraces: traces withProfile: profile
	| b groups |
	b := RTMondrian new.
	b shape rectangle
		borderColor: Color black;
		color: Color transparent.
	groups := (traces groupedBy: [ :x | x root ifNil: [ Object new ] ]).
	profile ifNotNil: [ 
		groups := groups select: [ :group | | samples |
			samples := group inject: 0 into: [ :acc :tr | acc + (profile traceAll: tr traceno) ].
			samples > 0 ifTrue: [Transcript show: samples; show: ' '; show: profile totalSamples; cr. ].
			samples > 0.1  ]
		].
	b nodes: groups
		forEach: [ :group |
		b shape rectangle
			color: [ :tr | Color red alphaMixed: (profile traceAll: tr traceno) with: Color white ];
			borderColor: Color black;
			size: 100;
			withTextAbove: [ :tr | 'Trace ', tr traceno asString ].
		b nodes: group value.
		b layout dominanceTree.
		b edges connectFrom: #parent. ].
	b layout flow.
	^ b build.
