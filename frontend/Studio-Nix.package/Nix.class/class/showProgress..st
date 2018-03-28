private
showProgress: aString 
	aString asByteArray utf8Decoded withSqueakLineEndings linesDo: [ :line |
		Transcript show: line; cr.
		({ 'building path(s) *'. 'error: build of *'. 'fetching path *'} anySatisfy: [ :pattern |
			pattern match: line ]) ifTrue: [ 
				"Abbreviate nix store paths"
				UIManager default inform: (line copyWithRegex: '/nix/store/[^-]+-' matchesReplacedWith: '').
			 ]. ].
