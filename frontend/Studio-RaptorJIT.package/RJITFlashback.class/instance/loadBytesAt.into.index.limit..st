accessing
loadBytesAt: anAddress into: anArray index: anIndex limit: aLimit
	| start end |
	start := address.
	end := address + data size.
	anIndex >= anArray size ifTrue: [ ^ anIndex ]. "Complete."
	anAddress + anIndex > aLimit ifTrue: [ ^anIndex ]. "Backtrack."
	(anAddress + anIndex >= start and: anAddress + anIndex < end)
		ifTrue: [ 
			"Load the first byte."
			anArray at: anIndex + 1 put: (data at: anAddress + anIndex - start + 1).
			"Recurse for more."
			^ self loadBytesAt: anAddress into: anArray index: anIndex + 1 limit: aLimit. ]
		ifFalse: [ 
			"Search for a matching flashback."
			previous
				ifNil: [
					^ anIndex ]
				ifNotNil: [
					| newLimit |
					newLimit := start > anAddress ifTrue: [ aLimit min: start ] ifFalse: [ aLimit ].
					^ previous loadBytesAt: anAddress into: anArray index: anIndex limit: newLimit ] ].
