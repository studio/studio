*studio-extensions
withText: aSymbolOrABlock height: anIntegerOrABlock color: aColor
	shape := shape + (RTLabel new text: aSymbolOrABlock; height: anIntegerOrABlock; color: aColor).
	^ shape