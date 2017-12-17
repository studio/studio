initialization
getBytes: size atAddress: address atTime: time
	| array stream block |
	array := ByteArray ofSize: size.
	stream := array writeStream.
	block := [ :page :i |
		| byte |
		byte := page at: i.
		byte = -1 ifTrue: [ RJITFlashbackDataMissing new signal ].
		stream nextPut: byte ].
	self do: block address: address bytes: size time: time create: false.
	stream close.
	^ array.