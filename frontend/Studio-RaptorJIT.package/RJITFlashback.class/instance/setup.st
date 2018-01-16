initialization
setup
	"Setup linkage to earlier flashbacks (if any.)"
	previous
		ifNil: [ 
			time := 0.
			image := RJITFlashbackImage new. ]
		ifNotNil: [ 
			time := previous time + 1.
			image := previous image. ].
	"Store data."
	image setBytes: data atAddress: address atTime: time.