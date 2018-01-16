accessing-data
trace: tr
	^ traces detect: [ :profile | profile id = tr traceno ].