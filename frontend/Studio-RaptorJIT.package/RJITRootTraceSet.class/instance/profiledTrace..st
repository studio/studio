accessing
profiledTrace: tr
	^ RJITTraceWithProfile new
		trace: tr;
		profile: (profile trace: tr);
		children: (traces select: [ :child | child parent = tr and: [ child isRootTrace not ] ]
								thenCollect: [ :child | self profiledTrace: child ]).
