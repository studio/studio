initialization
setPage: page atAddress: address atTime: time
	(pages at: address ifAbsentPut: [ Heap sortBlock: [ :a :b | a key < b key ]])
		add: time -> page.
