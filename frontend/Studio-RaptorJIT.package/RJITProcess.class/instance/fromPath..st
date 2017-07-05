instance creation
fromPath: path
	self dwarf: (DWARF loadFromFileNamed: path, '/raptorjit-dwarfish.json').
	self auditLog: (RJITAuditLog loadFromFileNamed: path, '/audit.log' withDWARF: self dwarf).
	self vmProfile: (RJITVMProfile loadFromFileNamed: path, '/raptorjit.vmprofile') named: 'default'.