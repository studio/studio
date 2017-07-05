printing
print: aValue on: aStream
   aStream nextPutAll: '<', self printString, '>'.