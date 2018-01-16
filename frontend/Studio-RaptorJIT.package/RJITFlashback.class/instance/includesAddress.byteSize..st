accessing
includesAddress: anAddress byteSize: size
	[ self bytesAt: anAddress size: size ] on: RJITFlashbackDataMissing do: [ ^ false ].
	^ true.
