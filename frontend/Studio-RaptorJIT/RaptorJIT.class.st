Class {
	#name : #RaptorJIT,
	#superclass : #Object,
	#category : #'Studio-RaptorJIT'
}

{ #category : #running }
RaptorJIT class >> eval: luaSource [
	| tmpdir tmp build |
	tmpdir := FileReference newTempFilePrefix: 'studio-lua-eval-' suffix: ''.
	^[ 
		tmpdir ensureCreateDirectory.
		tmp := tmpdir / 'eval.lua'.
		tmp writeStream nextPutAll: luaSource; close.
		build := NixBuild onCode: 'with import <studio>; raptorjit.runCode ', tmpdir pathString.
		RJITProcess new fromPath: build firstOutput
	] ensure: [ tmpdir ensureDeleteAll ].
]

{ #category : #running }
RaptorJIT class >> inspect: aPath [
	^ RJITProcess new fromPath: aPath parent
]

{ #category : #running }
RaptorJIT class >> inspectAll: aPath [
	| paths logs progress num |
	paths := aPath asFileReference allChildrenMatching: 'audit.log'.
	progress := 0.
	num := paths size.
	[  :job |
		job title: 'Reading logs' translated.
		logs := paths collect: [ :log |
			| shortPath |
			shortPath := (GtFileUtility fileNameOf: log parent relativeTo: aPath asFileReference).
			job title: ('Reading log {1}/{2}: {3}' format: { progress + 1. num. shortPath. }).
			job progress: progress / num.
			progress := progress + 1.			(self inspect: log) name: shortPath.
			 ]
		 ] asJob run.
	^ (SnabbProcessList withAll: logs) sorted: [ :a :b | a name < b name ]
]

{ #category : #running }
RaptorJIT class >> inspectBuild: build [
	^ self load: build firstOutput
]

{ #category : #running }
RaptorJIT class >> load: aPath [
	^ self inspectAll: aPath
]

{ #category : #running }
RaptorJIT class >> loadUrl: aUrl [
	| expr |
	expr := 'with import <studio>; raptorjit.inspectUrl "', aUrl, '"'.
	^ self inspectBuild: (NixBuild onCode: expr).

]

{ #category : #running }
RaptorJIT class >> runPath: aPath [
	| ref expr |
	ref := aPath asFileReference.
	expr := 'with import <studio>; raptorjit.runCode ', ref pathString.
	^ self inspectBuild: (NixBuild onCode: expr).

]

{ #category : #running }
RaptorJIT class >> runUrl: aURL [
	| expr |
	expr := 'with import <studio>; raptorjit.runURL "', aURL, '"'.
	^ self inspectBuild: (NixBuild onCode: expr).

]

{ #category : #testing }
RaptorJIT class >> test [
	^ RJITExamples all collect: #test.
]
