scripting opening
open
	| window |
	window := self openOn: StudioWelcome new.
	self browser selection: 42.
	^window.