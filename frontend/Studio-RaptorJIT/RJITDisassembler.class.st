Class {
	#name : #RJITDisassembler,
	#superclass : #Object,
	#category : #'Studio-RaptorJIT'
}

{ #category : #'as yet unclassified' }
RJITDisassembler class >> disassemble: byteArray [
	^ self disassemble: byteArray address: 0
]

{ #category : #accessing }
RJITDisassembler class >> disassemble: byteArray address: address [
	| tmp proc stdout |
	tmp := FileReference newTempFilePrefix: 'mcode' suffix: '.bin'.
	tmp binaryWriteStream nextPutAll: byteArray asByteArray; close.
	proc := GtUnixSubprocess command: '/usr/bin/env' arguments: {
		'disasm'.
		tmp fullName.
		'0x', (address radix:16).
	}.
	proc runAndWait.
	^ proc stdout copyReplaceAll: String tab with: '  '.

]
