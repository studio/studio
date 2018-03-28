instance creation
realize: deriv
	^(self command: 'nix-store --realize ', deriv) lines.