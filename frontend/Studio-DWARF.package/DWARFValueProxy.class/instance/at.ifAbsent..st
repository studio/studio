accessing
at: name ifAbsent: aBlock
   ^ (DWARFValueProxy on: ((dwarfValue child: name) ifNil: [ ^aBlock value ])) simplify.
