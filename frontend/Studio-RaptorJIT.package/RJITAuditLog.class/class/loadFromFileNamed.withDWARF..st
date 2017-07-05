instance creation
loadFromFileNamed: fileName withDWARF: dwarf
	^self new dwarf: dwarf; loadFromFileNamed: fileName.
