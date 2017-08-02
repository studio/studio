instance creation
instantiate: expression
	| tmp |
	tmp := FileReference newTempFilePrefix: 'eval-' suffix: '.nix'.
	tmp writeStream nextPutAll: expression; cr; close.
	[ ^ (self command: 'nix-instantiate ', tmp pathString) lines ]
		ensure: [ tmp delete ].