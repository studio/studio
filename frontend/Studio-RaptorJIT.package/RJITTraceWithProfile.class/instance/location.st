accessing
location
	^ 'dummy.lua:' , ((trace start value at: 1) value % 300) asString.