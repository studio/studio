accessing
decode: byteArray address: address flashback: flashback
   | pointerAddress present |
   [ byteArray size = 8 ] assert. "XXX"
   pointerAddress := byteArray unsignedLongLongAt: 1.
   present := flashback includesAddress: pointerAddress byteSize: type byteSize.
   present ifFalse: [ pointerAddress := pointerAddress negated. ]. "missing pointer value is negative"
   ^DWARFValue type: self value: pointerAddress
               address: address flashback: flashback.