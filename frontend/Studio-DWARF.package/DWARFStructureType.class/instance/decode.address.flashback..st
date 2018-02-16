decoding
decode: byteArray address: address flashback: flashback
   [ byteSize notNil ] assert.
   ^DWARFValue
		type: self
		value: (members collect: [ :m | [ m decode: byteArray address: address flashback: flashback. ] ])
      address: address flashback: flashback.
