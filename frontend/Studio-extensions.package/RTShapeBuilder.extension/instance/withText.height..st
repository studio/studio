*studio-extensions
withText: aSymbolOrABlock height: anIntegerOrABlock
	shape := shape + (RTLabel new text: aSymbolOrABlock; height: anIntegerOrABlock).
	^ shape