private
newPageList
	^ SortedCollection sortBlock: [ :a :b | a key > b key ].