accessing
hasChildren: dwarfValue
	^ dwarfValue value > 0 and: type ~= DWARFVoid.