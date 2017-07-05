instance creation
childOf: dwValue named: aName
	| values |
	values := self children: dwValue.
	1 to: members size do: [ :i | | member |
		member := members at: i.
		member name = aName ifTrue: [ ^values at: i ].
		member type isAnonymousStructure ifTrue: [
		(member type childOf: (values at: i) named: aName) ifNotNil: [ :x | ^x ]. ].
		].
