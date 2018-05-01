Extension { #name : #RTElement }

{ #category : #'*Studio-Extension' }
RTElement >> connectedEdgesLongTree [
	"Return the full set of transitive connected edges as a tree.
	If a node has two parents then prune to maximize the depth of the tree."
	| seen memo depth |
	memo := IdentityDictionary new.
	seen := IdentitySet new.
	depth := [ :v |
		memo at: v ifAbsentPut: [ 
			(seen includes: v)
				ifTrue: [ 0 ]
				ifFalse: [
					seen add: v.
					1 + (self connectedEdges inject: 0 into: [ :acc :e | acc max: (depth value: e) ])
					]
			 ].
		 ].
	^ depth value: self.

]
