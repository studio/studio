tests
testNumber
	self parse: '1234' rule: #number.
	self parse: '0x9' rule: #number.
	self parse: '0x1234abc' rule: #number.