Extension { #name : #Collection }

{ #category : #'*studio-raptorjit' }
Collection >> irListViewIn: composite title: aTitle [
	"For a Collection of RJITIrInstruction instances."
	composite fastTable 
		title: aTitle;
		display: self;
		column: 'Num' evaluated: #irRefString width: 40;
		column: 'Loc' evaluated: #irRegisterString width: 40;
		column: 'Flags' evaluated: #irFlagsString width: 40;
		column: 'Opcode' evaluated: #opcode width: 50;
		column: 'Operands' evaluated: #operandsString width: 1000;
		addAction: [
			String streamContents: [ :s |
				self do: [ :i | 
					s nextPutAll: i irString; cr ] ]
		] gtInspectorActionCopyValueToClipboard.

]
