accessing
run
	derivations := Nix instantiate: code.
	builds := derivations flatCollect: [ :each | Nix realize: each ].
	outputs := builds collect: #asFileReference.