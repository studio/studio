accessing
samples
	^ traces sum: [ :tr | (profile trace: tr) all ].