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
