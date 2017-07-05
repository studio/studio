accessing
children: dwarfValue
   ^(self hasChildren: dwarfValue)
      ifTrue: [
	      { '' -> self dereference: dwarfValue. } ]
      ifFalse: [ {} ].
