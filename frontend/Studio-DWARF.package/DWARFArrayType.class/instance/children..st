printing
children: dwarfValue
   ^ (0 to: numberOfElements - 1) collect: [ :i | i -> (dwarfValue value at: i + 1). ].