printing
print: anInteger on: aStream
   aStream nextPutAll: type typename, ' @ 0x', (anInteger abs printStringBase: 16).
