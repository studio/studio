instance creation
gtInspectorVMProfilesIn: composite
	<gtInspectorPresentationOrder: 1>
	| w percent |
	w := 50. "width of numeric columns"
	^ composite tabulator
		title: 'VM Profile';
		with: [ :t |
			t row: #profiles; row: #locations; row: #traces.
			t transmit to: #profiles; andShow: [ :a |
				percent := [ :sel |
					[ :obj |
						[ ((obj perform: sel) round: 1) asString , '%' ] on: ZeroDivide do: [ '-' ] ] ].
				a fastTable
					title: 'Profiler datasets (VMProfile)';
					display: #vmprofiles;
					column: 'Profile' evaluated: #name width: 100;
					column: 'Samples' evaluated: #total width: 60;
					column: 'Mcode' evaluated: (percent value: #mcodePercent) width: w;
					column: 'VM' evaluated: (percent value: #vmPercent) width: w;
					column: 'GC' evaluated: (percent value: #gcPercent) width: w.	].
			t transmit from: #profiles; to: #locations; andShow: [ :a |
				a fastTable
					title: 'Source code locations of root traces that are hot in the selected profile';
					display: [ :profile | profile locations select: [ :x | x samples > 0 ] ];
					sorted: [ :x :y | x samples > y samples ];
					column: 'Location' evaluated: #location width: 240;
					column: 'Samples' evaluated: #samples width: 60;
					column: '#Root' evaluated: #numberOfRootTraces width: w;
					column: '#Side' evaluated: #numberOfSideTraces width: w. ].
			t transmit from: #locations; to: #traces; andShow: [ :a |
				a fastTreeTable
					title: 'Root traces starting at selected location (and their side-traces as children)';
					display: #profiledTraces;
					children: #children;
					sorted: [ :x :y | x samples > y samples ];
					column: 'Trace' evaluated: #traceno width: 160;
					column: 'Samples' evaluated: #samples width: 60;
					column: 'Link' evaluated: #linktype width: 60;
					column: 'Mcode' evaluated: (percent value: #mcodePercent) width: w;
					column: 'VM' evaluated: (percent value: #vmPercent) width: w;
					column: 'GC' evaluated: (percent value: #gcPercent) width: w;
					column: 'Start line' evaluated: #location width: 240;
					column: 'Stop line' evaluated: [ :x | '-' ] width: 240;
					allExpanded. ].
			t transmit toOutsidePort: #selection; from: #traces port: #selection transformed: #trace.
			].
