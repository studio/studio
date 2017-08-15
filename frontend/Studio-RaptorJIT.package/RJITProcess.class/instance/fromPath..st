instance creation
fromPath: aPath
	| dwarfPath auditPath |
	path := aPath.
	dwarfPath := path / 'raptorjit-dwarf.json'.
	auditPath := path / 'audit.log'.
	[ dwarfPath isFile and: auditPath isFile ] assertWithDescription:
		'JIT audit log not found'.
	auditLog := RJITAuditLog loadFromFileNamed: auditPath pathString withDWARF: (DWARF loadFromFileNamed: dwarfPath pathString).
	vmprofiles := OrderedCollection new.
	(path / 'vmprofile') children do: [ :vmprofile |
		vmprofiles add: (RJITVMProfile loadFromFileNamed: vmprofile pathString name: vmprofile basenameWithoutExtension process: self) ].