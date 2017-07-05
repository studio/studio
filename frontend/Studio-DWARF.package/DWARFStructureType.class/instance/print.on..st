printing
print: value on: aStream
   aStream nextPutAll: '<', self typename, '>'
