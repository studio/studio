Class {
	#name : #StudioLoader,
	#superclass : #Object,
	#category : #'Studio-Loader'
}

{ #category : #'load and saving' }
StudioLoader class >> load [ 
	self new loadAllStudioPackages.
	^ #Success.
]

{ #category : #'world menu' }
StudioLoader class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #StudioSave)
		order: 300.0;
		parent: #Studio;
		label: 'Save Studio code to disk';
		help: 'Save running Smalltalk code for Studio into <studio>/frontend/ directory';
		action: [ StudioLoader save. ].
	(aBuilder item: #StudioLoad)
		order: 310.0;
		parent: #Studio;
		label: 'Load Studio code from disk';
		help: 'Load Smalltalk code for Studio from <studio>/frontend/ directory';
		action: [
			(UIManager default proceed: 'Reload all Studio code from disk?')
				ifTrue: [ StudioLoader load. ] ].
]

{ #category : #'load and saving' }
StudioLoader class >> repo [
	^ self new repo
]

{ #category : #'load and saving' }
StudioLoader class >> save [ 
	self new saveAllStudioPackages.
	^ #Success.
]

{ #category : #internal }
StudioLoader class >> saveLoader [
	"Save a new version of the loader for bootstrapping a new image."
	TonelWriter fileOut: #'Studio-Loader' asPackage mcWorkingCopy on: Studio dir / 'backend' / 'frontend'.

]

{ #category : #'load and saving' }
StudioLoader >> loadAllStudioPackages [
	self loadAllStudioPackagesFrom: self repo.

]

{ #category : #'load and saving' }
StudioLoader >> loadAllStudioPackagesFrom: aDirectory [
	self packageNames do: [ :packageName |
		self loadPackage: packageName fromDirectory: aDirectory.
		UIManager default inform: 'Loaded ', packageName. ]
							displayingProgress: [ :name | 'Loading ', name ].

]

{ #category : #internal }
StudioLoader >> loadPackage: aPackageName fromDirectory: aDirectory [
	(TonelReader on: aDirectory fileName: aPackageName) version load.

]

{ #category : #'load and saving' }
StudioLoader >> packageNames [
	^ #(
	'Studio-Loader'
	'Studio-Nix'
	'Studio-DWARF'
	'Studio-RaptorJIT'
	'Studio-Snabb'
	'Studio-UI'
	'Studio-Extension'
	)


]

{ #category : #'load and saving' }
StudioLoader >> repo [
	^ (OSProcess thisOSProcess environment at: #STUDIO_PATH) asFileReference / #frontend

]

{ #category : #'load and saving' }
StudioLoader >> saveAllStudioPackages [
	self saveAllStudioPackagesTo: self repo.
]

{ #category : #'load and saving' }
StudioLoader >> saveAllStudioPackagesTo: aDirectory [
	self packageNames do: [ :packageName | 
		self savePackage: packageName toDirectory: aDirectory.
		UIManager default inform: 'Saved ', packageName. ]
							displayingProgress: [ :name | 'Saving ', name ].

]

{ #category : #internal }
StudioLoader >> savePackage: aPackageName toDirectory: aDirectoryPath [
	TonelWriter fileOut: aPackageName asPackage mcWorkingCopy on: aDirectoryPath.
]
