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
RaptorJIT class >> inspectBuild: build [
	^ RJITProcess new fromPath: build firstOutput
]

{ #category : #running }
RaptorJIT class >> load: aPath [
	| ref expr |
	ref := aPath asFileReference.
	expr := 'with import <studio>; raptorjit.inspect ', ref pathString.
	^ self inspectBuild: (NixBuild onCode: expr).

]

{ #category : #running }
RaptorJIT class >> loadUrl: aUrl [
	| expr |
	expr := 'with import <studio>; raptorjit.inspect (fetchTarball "', aUrl, '")'.
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
