Class {
	#name : #StudioDAGLayout,
	#superclass : #RTSugiyamaLayout,
	#category : #'Studio-Extension'
}

{ #category : #private }
StudioDAGLayout >> buildLayers: g [
	
	| w layerNr u vertices vertex layer done layersTmp layerNrsTmp |
	w := self maxFloat.
	u := OrderedCollection new.
	layers := IdentityDictionary new.
	layerNrs := IdentityDictionary new.	"Assign all nodes to layers"
	[g isEmpty]
		whileFalse:
			[vertices := g
				select:
					[:e | (self parentsFor: e) allSatisfy: [:node | u includes: node]].
			vertex := vertices detectMax: [:e | labels at: e].
			done := false.
			layerNr := 1.
			[done]
				whileFalse:
					[layer := layers
						at: layerNr
						ifAbsentPut: [OrderedCollection new].
					(layer size >= w
						or:
							[(self parentsFor: vertex) anySatisfy: [:n | (layerNrs at: n) >= layerNr]])
						ifTrue: [layerNr := layerNr + 1]
						ifFalse: [done := true]].
			layer add: vertex.
			layerNrs at: vertex put: layerNr.
			u add: vertex.
			g remove: vertex].
	layerNr := layers keys max.
	layersTmp := layers.
	layers := IdentityDictionary new.
	layerNrsTmp := layerNrs.
	layersTmp keysAndValuesDo: [ :k :v | layers at: layerNr - k + 1 put: v ].
	layerNrsTmp keysAndValuesDo: [ :k :v | layerNrs at: k put: layerNr - v + 1 ].

]
