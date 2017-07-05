tests
testId
	self parse: 'foo' rule: #id.
	self parse: 'foo99' rule: #id.
	self parse: 'foo_99' rule: #id.