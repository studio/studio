accessing
asIrModes
	"Special case: decode lj_ir_mode as a uint8_t array."
	^ ((0 to: data size - 1) collect: [ :i |
		i -> (RJITIRMode new from: (data at: i+1)) ]) asDictionary.