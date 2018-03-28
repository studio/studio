instance creation
openWithMessage: text
	| window ui |
	window := self new.
	window text: text.
	window extent: World extent * 0.8.
	window title: 'Error building Nix expression'.
	ui := window openWithSpec.
	window text on: Character space do: [ ui close ].
	window text on: Character escape do: [ ui close ].
	window text on: Character cr do: [ ui close ].
	window text scrollValue: 0@1.
	^ ui