instance creation
build: expr
	^(self instantiate: expr) collect: [ :deriv | self realize: deriv ].