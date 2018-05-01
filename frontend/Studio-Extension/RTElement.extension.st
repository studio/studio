Extension { #name : #RTElement }

{ #category : #'*Studio-Extension' }
RTElement class >> edgesForLongTree: elements [
	"Return the full set of transitive connected edges as a tree.
	If a node has two parents then prune to maximize the depth of the tree."
	| seen memo depth edges |
	memo := IdentityDictionary new.
	seen := IdentitySet new.
	edges := RTGroup new.
	depth := [ :v |
		memo at: v ifAbsentPut: [ 
			(seen includes: v)
				ifTrue: [ 0 ]
				ifFalse: [
					seen add: v.
					1 + (v incomingEdges inject: 0 into: [ :acc :e | acc max: (depth value: e to) ])
					]
			 ].
		 ].
	elements do: [ :e |
		e incomingEdges ifNotNil: [ :es |
			(es detectMax: [ :edge | depth value: edge to ])
				ifNotNil: [ :max | edges add: max ]
		] ].
	^ edges.

]
