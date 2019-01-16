Extension { #name : #FileReference }

{ #category : #'*studio-raptorjit' }
FileReference >> dumpStudioFile: aFilename with: aBlock [ 
	| file |
	file := self / aFilename.
	"Transcript show: 'Writing ', file pathString; cr."
	[ file writeStreamDo: aBlock ] on: Error do: [ :error |
		Transcript cr; show: 'Error on ', file pathString, ': ', error printString; cr.
		(file withExtension: '.error') writeStreamDo: [ :s | s nextPutAll: error printString; cr ]
	].
]
