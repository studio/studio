initializing
loadFromFileNamed: fileName
	| references |
	json := (NeoJSONReader on: (FileStream readOnlyFileNamed: fileName)) next.
	"References is a tag->object mapping where each object will #become: the real type."
	references := json collect: [ :_ | Object new ].
	types := json collect: [ :dict | self dwarfTypeOf: dict via: references ].
	"Walk the heap and replace reference objects with real type objects."
	references values elementsForwardIdentityTo: (references keys collect: [ :tag | types at: tag]).
	types := types values.