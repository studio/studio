Extension { #name : #String }

{ #category : #'*Studio-RaptorJIT' }
String >> asBytecodeInstructionType [
   ^ (self withoutPrefix: 'BC_') asLowercase asSymbol.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asIRInstructionName [
	^ (self withoutPrefix: 'IR_') asLowercase asSymbol.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asIRInstructionType [
   ^ (self withoutPrefix: 'IRT_') asLowercase asSymbol.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asLinkTypeName [
	^ (self withoutPrefix: 'LJ_TRLINK_') asLowercase asSymbol.

]
