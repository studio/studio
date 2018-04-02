Class {
	#name : #NixErrorWindow,
	#superclass : #ComposableModel,
	#instVars : [
		'button',
		'text'
	],
	#category : #'Studio-Nix'
}

{ #category : #layout }
NixErrorWindow class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :col |
			col
				newRow: [ :row | row add: #text. ];
				newRow: [ :row | row add: #button ] height: 30;
				yourself ].

]

{ #category : #'instance creation' }
NixErrorWindow class >> openWithMessage: text [
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
]

{ #category : #accessing }
NixErrorWindow >> button [
	^ button
]

{ #category : #initialization }
NixErrorWindow >> initializeWidgets [
	text := TextModel new disable; yourself.
	button := self newButton label: 'Dismiss' asText allBold; action: [ self window close ]; yourself.
	self focusOrder add: text.
]

{ #category : #accessing }
NixErrorWindow >> text [
	^ text
]

{ #category : #accessing }
NixErrorWindow >> text: aText [
	text text: aText
]

{ #category : #initialization }
NixErrorWindow >> windowIcon [
	^ self iconNamed: #error.
]
