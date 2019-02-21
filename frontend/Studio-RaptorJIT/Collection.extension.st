Extension { #name : #Collection }

{ #category : #'*studio-raptorjit' }
Collection >> irColumnedListViewIn: aView title: aTitle [
	| aList |
	aList := aView  columnedList
		title: aTitle translated;
		priority: 10;
		items: [ self ].
	
	aList column 
		title: 'Num' translated;
		width: 40;
		item: [ :item :index | item irRefString ].
		
	aList column 
		title: 'Loc' translated;
		width: 50;
		item: [ :item :index | item irRegisterString ].
		
	aList column
		title: 'F' translated;
		width: 10;
		item: [ :item :index | item irFlagsString ].
	
	aList column 
		title: 'Type' translated;
		width: 50;
		item: [ :item :index | item typename ].
		
	aList column
		title: 'Opcode' translated;
		width: 50;
		item: [ :item :index | item opcode ].
		
	aList column 	
		title: 'Operands' translated;
		matchParent;
		item: [ :item :index | item operandsString ].
		
	^ aList
]

{ #category : #'*studio-raptorjit' }
Collection >> irListViewIn: composite title: aTitle [
	"For a Collection of RJITIrInstruction instances."
	composite fastTable 
		title: aTitle;
		display: self;
		sorted: [ :a :b | a index < b index ];
		column: 'Num' evaluated: #irRefString width: 40;
		column: 'Loc' evaluated: #irRegisterString width: 40;
		column: 'Flags' evaluated: #irFlagsString width: 40;
		column: 'Type' evaluated: #typename width: 40;
		column: 'Opcode' evaluated: #opcode width: 50;
		column: 'Operands' evaluated: #operandsString width: 1000;
		addAction: [
			String streamContents: [ :s |
				self do: [ :i | 
					s nextPutAll: i irString; cr ] ]
		] gtInspectorActionCopyValueToClipboard.

]
