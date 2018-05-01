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
String >> asIrCallName [
	^ ((self withoutPrefix: #IRCALL_) asLowercase withoutPrefix: #lj_) replaceAll: $_ with: $.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asIrFieldName [
	^ (self withoutPrefix: #IRFL_) asLowercase replaceAll: $_ with: $.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asIrFloatOperationName [
	^ (self withoutPrefix: 'IRFPM_') asLowercase.

]

{ #category : #'*Studio-RaptorJIT' }
String >> asLinkTypeName [
	^ (self withoutPrefix: 'LJ_TRLINK_') asLowercase asSymbol.

]
