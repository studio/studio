Class {
	#name : #ConfigurationOfStudio,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfStudio
}

{ #category : #'development support' }
ConfigurationOfStudio class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>
]

{ #category : #private }
ConfigurationOfStudio class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #'ConfigurationOf'
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #'ConfigurationOf' ifAbsent: aBlock ].
]

{ #category : #private }
ConfigurationOfStudio class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfStudio class >> ensureMetacelloBaseConfiguration [
  Smalltalk
    at: #'ConfigurationOf'
    ifAbsent: [ 
      | repository version |
      repository := MCHttpRepository
        location: 'http://smalltalkhub.com/mc/dkh/metacello/main'
        user: ''
        password: ''.
      repository
        versionReaderForFileNamed: 'Metacello-Base-dkh.107'
        do: [ :reader | 
          version := reader version.
          version load.
          version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfStudio class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfStudio class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfStudio class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfStudio class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfStudio class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfStudio class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfStudio >> baseline01: spec [
	<version: '0.1-baseline'>
	
	spec for: #common do: [
		spec
			blessing: #baseline;
			repository: 'github://studio/studio:master/frontend'.
		
		spec
			package: 'Studio-Extension' with: [
				spec requires: #('Roassal2') ];
			package: 'Studio-Nix' with: [
				spec requires: #('Studio-Extension' 'NeoJSON' 'CommandShell') ];
			package: 'Studio-DWARF' with: [
				spec requires: #('Studio-Extension' 'NeoJSON') ];
			package: 'Studio-RaptorJIT' with: [
				spec requires: #('Studio-Extension' 'Studio-DWARF' 'Roassal2' 'MessagePack') ];
			package: 'Studio-UI' with: [ 
				spec requires: #('Studio-RaptorJIT') ].

		spec project: 'NeoJSON' with: [
			spec
				className: #ConfigurationOfNeoJSON;
				versionString: #'stable';
				repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo40/main/' ].
			
		spec project: 'Roassal2' with: [
			spec
				versionString: #'stable';
				className: #ConfigurationOfRoassal2;
				repository: 'http://www.smalltalkhub.com/mc/ObjectProfile/Roassal2/main' ].

		spec project: 'CommandShell' with: [ 
			spec
				versionString: #'stable';
				className: #ConfigurationOfCommandShell;
				repository: 'http://www.squeaksource.com/CommandShell' ].

		spec project: 'MessagePack' with: [ 
			spec
				versionString: #'stable';
				className: #ConfigurationOfMessagePack;
				repository: 'http://smalltalkhub.com/mc/MasashiUmezawa/MessagePack/main'. ].

		spec baseline: 'Tonel' with:
			[ spec repository: 'github://pharo-vcs/tonel' ].

		spec baseline: 'PetitParser2' with:
			[ spec repository: 'github://kursjan/petitparser2' ].

		].
]

{ #category : #accessing }
ConfigurationOfStudio >> customProjectAttributes [
    "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes "

    ^ #()
]

{ #category : #baselines }
ConfigurationOfStudio >> development: spec [
	<symbolicVersion: #development>
	
	spec for: #common version: '0.1-baseline'.
]

{ #category : #accessing }
ConfigurationOfStudio >> project [
    ^ project
        ifNil: [ 
            "Bootstrap Metacello if it is not already loaded"
            self class ensureMetacello.
            project := MetacelloMCProject new projectAttributes: self customProjectAttributes.	"Create the Metacello project"
            (Smalltalk at: #'MetacelloVersionConstructor') on: self project: project.	"Construct the project"
            project loadType: #'linear'.	"change to #atomic if desired"
            project ]
]
