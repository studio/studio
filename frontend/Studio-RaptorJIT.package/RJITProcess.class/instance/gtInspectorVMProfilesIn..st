instance creation
gtInspectorVMProfilesIn: composite
	<gtInspectorPresentationOrder: 6>
	| percent |
	percent := [ :selector |
					[ :object |
						(100 * (object perform: selector) / object totalSamples) asFloat rounded asString , '%' ] ].
	^ composite fastTable
		title: 'VMProfiles';
		display: #vmprofiles;
		column: 'Profile' evaluated: #name width: 100;
		column: 'Samples' evaluated: #totalSamples width: 100;
		column: 'JIT Head' evaluated: (percent value: #totalTraceHead) width: 80;
		column: 'JIT Loop' evaluated: (percent value: #totalTraceLoop) width:80 ;
		column: 'JIT FFI' evaluated: (percent value: #totalTraceFFI) width: 80;
		column: 'GC' evaluated: (percent value: #totalTraceGC) width: 80;
		column: 'Interpret' evaluated: (percent value: #totalInterpreter) width: 80;
		column: 'Runtime/C' evaluated: (percent value: #totalC) width: 80;
		column: 'Trace Exit' evaluated: (percent value: #totalExit) width: 80;
		column: 'Recording' evaluated: (percent value: #totalRecording) width: 80;
		column: 'Optimize' evaluated: (percent value: #totalOptimize) width: 80;
		column: 'Assemble' evaluated: (percent value: #totalAssemble) width: 80.
		
