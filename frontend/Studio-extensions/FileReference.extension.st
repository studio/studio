Extension { #name : #FileReference }

{ #category : #'*Studio-Extensions' }
FileReference >> gtInspectorStudioProductIn: composite [
	<gtInspectorPresentationOrder: 0>
	| productInfo dwarfJson auditLog |
	productInfo := self / '.studio/product-info.yaml'.
	productInfo isFile ifFalse: [ ^self ].
	"Product info as text"
	productInfo gtInspectorContentsIn: composite.
	"JIT data"
	dwarfJson := self / 'raptorjit-dwarf.json'.
	auditLog := self / 'audit.log'.
	(dwarfJson isFile and: auditLog isFile) ifTrue: [
		composite roassal2 title: 'JIT'; initializeView: [ 
			(RJITAuditLog loadFromFileNamed: auditLog pathString
							  withDWARF: (DWARF loadFromFileNamed: dwarfJson pathString)) visualizeMondrianOverview ] ].
]
