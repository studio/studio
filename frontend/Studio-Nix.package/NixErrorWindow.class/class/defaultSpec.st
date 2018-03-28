layout
defaultSpec
	^ SpecLayout composed
		newColumn: [ :col |
			col
				newRow: [ :row | row add: #text. ];
				newRow: [ :row | row add: #button ] height: 30;
				yourself ].
