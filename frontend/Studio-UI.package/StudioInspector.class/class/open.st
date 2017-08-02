instance creation
open
	| inspector |
	inspector := self new.
	inspector
		showFirst: [ :composite |
			composite text
				title: 'Nix expression';
				populate: #selection iconName: #glamorousGo on: $G entitled: 'Build' with: [ :editor | inspector go: editor text. ] ].
	^inspector openOn: 'with import <studio>;
'.