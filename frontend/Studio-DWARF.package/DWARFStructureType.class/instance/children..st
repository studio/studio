decoding
children: dwarfValue
   | values |
   values := dwarfValue value.
	^ (1 to: members size) collect: [ :i | (members at: i) name -> (values value at: i) ].
