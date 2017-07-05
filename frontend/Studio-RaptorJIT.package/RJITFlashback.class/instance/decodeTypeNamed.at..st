decoding
decodeTypeNamed: typename at: anAddress
   ^ self decodeType: (auditLog dwarf typeNamed: typename) at: anAddress.
