initialization
initializeWidgets
	text := TextModel new disable; yourself.
	button := self newButton label: 'Dismiss' asText allBold; action: [ self window close ]; yourself.
	self focusOrder add: text.