*Studio-RaptorJIT
asBytecodeInstructionType
   ^ (self withoutPrefix: 'BC_') asLowercase asSymbol.
