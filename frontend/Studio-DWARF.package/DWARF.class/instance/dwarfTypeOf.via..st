initializing
dwarfTypeOf: dict via: references
	| tag |
	tag := dict at: 'tag'.
	tag = 'base_type' ifTrue: [ ^DWARFBaseType new from: dict. ].
	tag = 'typedef' ifTrue: [ ^DWARFTypeDef new from: dict via: references. ].
	tag = 'pointer_type' ifTrue: [ ^DWARFPointerType new from: dict via: references. ].
	tag = 'const_type' ifTrue: [ ^ DWARFConstType new from:dict via: references. ].
	tag = 'structure_type' ifTrue: [ ^DWARFStructureType new from: dict via: references. ].
	tag = 'enumeration_type' ifTrue: [ ^DWARFEnumerationType new from: dict via: references. ].
	tag = 'array_type' ifTrue: [ ^DWARFArrayType new from: dict via: references. ].
	tag = 'union_type' ifTrue: [ ^DWARFUnionType new from: dict via: references. ].
	^DWARFUnrecognizedType new from: dict.