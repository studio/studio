accessing
location
	^ 'dummy.lua:' , ((location at: 1) value % 300) asString.
