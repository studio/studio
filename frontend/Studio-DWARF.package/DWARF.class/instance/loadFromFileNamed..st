initialization
loadFromFileNamed: fileName
	| references  |
	json := (NeoJSONReader on: (FileStream readOnlyFileNamed: fileName)) next.
	"References is a tag->object mapping where each object will #become: the real type."
	references := json collect: [ :_ | Object new ].
	alltypes := json collect: [ :dict | self dwarfTypeOf: dict via: references ].
	"Walk the heap and replace reference objects with real type objects."
	references values elementsForwardIdentityTo: (references keys collect: [ :tag | alltypes at: tag]).
	types := Dictionary new.
	alltypes do: [ :type |
		| name |
		name := type typename asSymbol.
		(types includesKey: name) ifFalse: [ types at: name put: type ] ].