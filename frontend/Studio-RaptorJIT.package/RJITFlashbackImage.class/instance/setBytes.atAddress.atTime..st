initialization
setBytes: array atAddress: address atTime: time
	| stream block |
	stream := array readStream.
	block := [ :page :i | page at: i put: stream next ].
	self do: block address: address bytes: array size time: time create: true.
