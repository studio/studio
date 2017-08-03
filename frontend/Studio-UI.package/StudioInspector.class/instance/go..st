scripting opening
go: code
	^ RJITProcess new fromPath: (NixBuild onCode: code) firstOutput.