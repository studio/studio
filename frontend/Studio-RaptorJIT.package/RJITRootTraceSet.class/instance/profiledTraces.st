accessing
profiledTraces
	^ traces select: #isRootTrace thenCollect: [ :tr | self profiledTrace: tr ].
