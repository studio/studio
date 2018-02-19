decoding
decode: byteArray address: address flashback: flashback
   [ byteSize notNil ] assert.
   ^DWARFValue
		type: self
		value: (members collect: [ :m |
			"This elaborate use of square brackets is meant as a simple way to
			 memoize the member decoding by caching the first value in a closure.
			 Maybe weird to do it this way in Smalltalk? It would be fairly idiomatic
			 Common Lisp:
				(let ((cache nil))
				  (lambda ()
			 	   (or cache (setf cache (do-something-expensive)))))
			"
			[ | value |
				[ value ifNil: [
					value := m decode: byteArray address: address flashback: flashback.
					value ] ] ] value.
		])
      address: address
		flashback: flashback.
