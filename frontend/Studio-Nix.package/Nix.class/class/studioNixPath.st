as yet unclassified
studioNixPath
	"XXX The user needs to know about this somehow..."
	^ OSProcess thisOSProcess environment
		at: #STUDIO_PATH
		ifAbsent: OSProcess thisOSProcess getCwd.