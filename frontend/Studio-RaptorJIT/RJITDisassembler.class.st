Class {
	#name : #RJITDisassembler,
	#superclass : #Object,
	#category : #'Studio-RaptorJIT'
}

{ #category : #'as yet unclassified' }
RJITDisassembler class >> disassemble: byteArray [
	^ self disassemble: byteArray address: 0
]

{ #category : #'as yet unclassified' }
RJITDisassembler class >> disassemble: byteArray address: address [
	| tmp proc |
	tmp := FileReference newTempFilePrefix: 'mcode' suffix: '.bin'.
	tmp binaryWriteStream nextPutAll: byteArray asByteArray; close.
	proc := PipeableOSProcess command: 'disasm ', tmp fullName, ' 0x', (address radix: 16).
	^ proc output.

]
