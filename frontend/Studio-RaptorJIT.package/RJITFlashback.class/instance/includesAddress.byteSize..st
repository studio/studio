accessing
includesAddress: anAddress byteSize: size
   [ self bytesAt: anAddress size: size ] on: SubscriptOutOfBounds do: [ ^false ].
   ^true.
