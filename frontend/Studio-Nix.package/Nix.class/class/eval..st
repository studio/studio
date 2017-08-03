as yet unclassified
eval: expression
	| tmp process outputs |
	tmp := FileReference newTempFilePrefix: 'eval-' suffix: '.nix'.
	tmp writeStream nextPutAll: expression; cr; close.
	process := PipeableOSProcess command: 'nix-instantiate --eval --strict --xml ', tmp pathString.
	outputs := process outputAndError collect: [ :m | TextConverter default convertFromSystemString: m ].
	process succeeded ifFalse: [ NixError new messageText: (outputs at: 2); signal ].
	tmp delete.
	^XMLDOMParser parse: (outputs at: 1).